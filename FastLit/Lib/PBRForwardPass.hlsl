#if !defined(PBR_FORWARD_PASS_HLSL)
#define PBR_FORWARD_PASS_HLSL

#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/Lib/BSDF.hlsl"
#include "../../PowerShaderLib/Lib/Colors.hlsl"

#define _SPHERE_FOG_LAYERS
#include "../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../PowerShaderLib/URPLib/Lighting.hlsl"

#include "../../PowerShaderLib/Lib/NatureLib.hlsl"
#include "../../PowerShaderLib/Lib/WeatherNoiseTexture.hlsl"
#include "../../PowerShaderLib/URPLib/URP_MotionVectors.hlsl"
#include "../../PowerShaderLib/Lib/BigShadows.hlsl"
#include "../../PowerShaderLib/Lib/PowerUtils.hlsl"
#include "../../PowerShaderLib/Lib/ParallaxLib.hlsl"
#include "../../PowerShaderLib/Lib/CurvedLib.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1:TEXCOORD1;
    // float2 uv2:TEXCOORD2;
    DECLARE_MOTION_VS_INPUT(prevPos);
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    float4 color:COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 uv : TEXCOORD0; // mainUV,lightmapUV
    float4 vertex : SV_POSITION;
    // TANGENT_SPACE_DECLARE(1,2,3);
    float4 tSpace0:TEXCOORD1;
    float4 tSpace1:TEXCOORD2;
    float4 tSpace2:TEXCOORD3;
    // float4 shadowCoord:TEXCOORD4;
    float4 fogCoord:TEXCOORD5;//fogCoord{x,y}, z:heightColorAtten
    // motion vectors
    #if defined(OUTPUT_MOTION)
    DECLARE_MOTION_VS_OUTPUT(6,7);
    #endif
    float4 bigShadowCoord:TEXCOORD8;
    float4 vertexPos:TEXCOORD9;
    float3 viewDirTS:TEXCOORD10;
    float4 color:COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f vert (appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);

    float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
    float3 worldNormal = normalize(TransformObjectToWorldNormal(v.normal));
    float3 worldTangent = normalize(TransformObjectToWorldDir(v.tangent.xyz));

    float4 attenParam = v.color.x; // vertex color atten
    #if defined(_WIND_ON)
    branch_if(IsWindOn())
    {
        worldPos = WindAnimationVertex(worldPos,v.vertex.xyz,worldNormal,attenParam * _WindAnimParam, _WindDir,_WindSpeed).xyz;
    }
    #endif

    worldPos.xy += CalcCurvedPos(_WorldSpaceCameraPos,worldPos,_CurvedSidewayScale,_CurvedBackwardScale);

    o.vertex = UnityWorldToClipPos(worldPos);
    o.vertexPos = v.vertex;
    o.uv.xy = v.uv;
    o.uv.zw = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
    #if defined(_STOREY_ON)
    // if(_StoreyTilingOn)
    {
        o.uv.y = WorldHeightTilingUV(worldPos,_StoreyHeight);
    }
    #endif

    TANGENT_SPACE_COMBINE_WORLD(worldPos,worldNormal,float4(worldTangent,v.tangent.w * unity_WorldTransformParams.w),o/**/);
    // o.shadowCoord = TransformWorldToShadowCoord(worldPos);
    o.fogCoord.xy = CalcFogFactor(p.xyz,o.vertex.z,_HeightFogOn,_DepthFogOn);

    half upFaceAtten = 1;
    // #if defined(_EMISION_HEIGHT_ON)
    branch_if(_EmissionHeightOn)
    {
    upFaceAtten = 1 - saturate(dot(worldNormal,half3(0,1,0)));
    upFaceAtten = lerp(1,upFaceAtten,_EmissionHeightColorNormalAttenOn);
    }
    // #endif

    o.fogCoord.z = upFaceAtten;

    o.color = v.color;

    #if defined(OUTPUT_MOTION)
    CALC_MOTION_POSITIONS(v.prevPos,v.vertex,o,o.vertex);
    #endif
    
    branch_if(!_BigShadowOff){
        float3 bigShadowCoord = TransformWorldToBigShadow(worldPos);
        o.bigShadowCoord.xyz = bigShadowCoord;
    }

    #if defined(_PARALLAX)
    branch_if(_ParallaxOn){
        float3 viewDirWS = normalize(_WorldSpaceCameraPos - worldPos);
        o.viewDirTS.xyz = (float3(
            dot(worldTangent,viewDirWS),
            dot(b,viewDirWS),
            dot(worldNormal,viewDirWS)
        ));
    }
    #endif
    return o;
}

float4 frag (v2f i
#if defined(OUTPUT_NORMAL)
,out float4 outputNormal:SV_TARGET1
#endif

#if defined(OUTPUT_MOTION)
,out float4 outputMotionVectors:SV_TARGET2
#endif

#if defined(OUTPUT_WORLD_POS)
,out float4 outputPos:SV_TARGET3
#endif
) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);

    TANGENT_SPACE_SPLIT(i);

    #if defined(_PARALLAX)
        branch_if(_ParallaxOn)
        ApplyParallax(i.uv.xy/**/,i.viewDirTS.xyz,_ParallaxHeight,_ParallaxMapChannel,1,_ParallaxMap_ST); // move to vs
    #endif

    float2 mainUV = TRANSFORM_TEX(i.uv.xy, _MainTex);
    float2 normalUV = i.uv.xy *_NormalMap_ST.xy + _NormalMap_ST.zw;
    float2 pbrMaskUV = i.uv.xy * _PbrMask_ST.xy + _PbrMask_ST.zw;
    float2 lightmapUV = i.uv.zw;
    float2 screenUV = i.vertex.xy/_ScaledScreenParams.xy;
//---------- rain
    //========  rain 1 input.uv apply rain flow
    #if defined(_RAIN_ON)
    half rainIntensity = _GlobalRainIntensity * _RainIntensity;
    half rainNoise = 0;
    half rainAtten = 0;
    branch_if(IsRainOn())
    {
        // flow atten
        rainAtten = GetRainFlowAtten(worldPos,normal,rainIntensity,_RainSlopeAtten,_RainHeight);
        mainUV += GetRainFlowUVOffset(rainNoise/**/,rainAtten,worldPos,_RainFlowTilingOffset,_RainFlowIntensity);
    }
    #endif
//-------- albedo
    float4 mainTex = tex2D(_MainTex, mainUV) * _Color;
    float alpha = mainTex.w;
    float3 albedo = mainTex.xyz;
    albedo *= _AlbedoMulVertexColor ? i.color.xyz : 1;
    albedo *= _AlphaPremultiply ? alpha : 1;

//---------- pbrMask
    float4 pbrMask = tex2D(_PbrMask,pbrMaskUV);
    float metallic = 0;
    float smoothness =0;
    float occlusion =0;
    SplitPbrMaskTexture(metallic/**/,smoothness/**/,occlusion/**/,pbrMask,int3(0,1,2),float3(_Metallic,_Smoothness,_Occlusion),false);

//---------- pbrMask details
    #if defined(_DETAIL_ON)
        // branch_if(_DetailWorldPosTriplanar)
        // {
        //     pbrMask = TriplanarSample(_DetailPBRMaskMap,sampler_DetailPBRMaskMap,worldPos,normalWS,_DetailPBRMaskMap_ST);
        // }else
        {
            // 1 plane sample
            float2 uv = CalcWorldUV(worldPos,_DetailWorldPlaneMode,_DetailPBRMaskMap_ST);
            pbrMask = SAMPLE_TEXTURE2D(_DetailPBRMaskMap,sampler_DetailPBRMaskMap,uv);
        }
        half3 pbrMaskScale = half3(_DetailPBRMetallic,_DetailPBRSmoothness,_DetailPBROcclusion);
        half3 detailPbrMaskApplyRate = half3(_DetailPbrMaskApplyMetallic,_DetailPbrMaskApplySmoothness,_DetailPbrMaskApplyOcclusion);

        ApplyDetailPbrMask(metallic/**/,smoothness/**/,occlusion/**/,pbrMask,pbrMaskScale,detailPbrMaskApplyRate);
    #endif


//---------- normal
    float3 tn = UnpackNormalScale(tex2D(_NormalMap,normalUV),_NormalScale);
//-------- rain ripple 
    #if defined(_RAIN_ON)
    branch_if(IsRainOn())
    {
        branch_if(_RippleIntensity)
        {
            rainAtten *= GetRainRippleAtten(smoothness,alpha,_RainMaskFrom);
            float2 rippleUV = CalcRippleUV(worldPos,_RippleTex_ST,_RippleOffsetAutoStop);
            float3 ripple = CalcRipple(_RippleTex,sampler_RippleTex,rippleUV,_RippleSpeed,_RippleIntensity);
            ripple *= rainAtten;
            // apply ripple color 
            albedo += ripple.x * _RippleAlbedoIntensity;

            // apply ripple blend normal
            tn += ripple * _RippleBlendNormal;
            // change pbr mask
        }

        // change pbr mask
        ApplyRainPbr(albedo/**/,metallic/**/,smoothness/**/,_RainColor,_RainMetallic,_RainSmoothness,rainIntensity);
    }
    #endif
    float3 n = normalize(TangentToWorld(tn,i.tSpace0,i.tSpace1,i.tSpace2));
//-------- snow
    #if defined(_SNOW_ON)
    branch_if(IsSnowOn())
    {
        float3 startPos = unity_ObjectToWorld._14_24_34 + i.vertexPos.xyz;
        float4 snowColor_Noise = CalcNoiseSnowColor(albedo,1,(startPos+startPos.xzy)*0.5,float4(_SnowNoiseTiling.xy,0,0),_SnowNoiseWeights);

        half snowAtten = (_SnowIntensityUseMainTexA ? alpha : 1) * _SnowIntensity;
        // snowAtten *= pbrMask.w;        
        albedo = MixSnow(albedo,snowColor_Noise.xyz,snowAtten,n,_ApplyEdgeOn);

        // snow normal mask
        float snowMask = smoothstep(0.4,0.7,snowColor_Noise.w);
        n = _SnowNormalMask ? lerp(1,n,snowMask) : n;
    }
    #endif    

//---------- roughness
    float roughness = 0;
    float a = 0;
    float a2 = 0;
    CalcRoughness(roughness/**/,a/**/,a2/**/,smoothness);
//---------- surface color 
    float3 specColor = lerp(0.04,albedo,metallic);
    // if(_TFOn)
    // {
    //     float3 thinFilm = ThinFilm(1- nv,_TFScale,_TFOffset,_TFSaturate,_TFBrightness);
    //     specColor = (specColor+1) * thinFilm;
    // }
    float3 diffColor = albedo.xyz * (1- metallic);

//-------- lighting prepare 
    float4 shadowMask = SampleShadowMask(lightmapUV);
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord,worldPos,shadowMask,_MainLightShadowSoftScale);
    branch_if(!_BigShadowOff)
    {
        // i.bigShadowCoord.z += 0.001;
        float atten = CalcBigShadowAtten(i.bigShadowCoord.xyz,1);
        mainLight.shadowAttenuation = min(mainLight.shadowAttenuation,atten);
    }

    branch_if(_CustomLightOn)
    {
        OffsetLight(mainLight/**/,specColor/**/,_CustomLightColorUsage,_CustomLightDir.xyz,_CustomLightColor.xyz);    
    }

    float3 l = mainLight.direction;
    float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
    float3 h = normalize(l+v);
    
    float lh = saturate(dot(l,h));
    float nh = saturate(dot(n,h));
    float nl = saturate(dot(n,l));
    float nv = saturate(dot(n,v));

    float3 radiance = mainLight.color * (nl * mainLight.shadowAttenuation * mainLight.distanceAttenuation);

//-------- output mrt
#if defined(OUTPUT_NORMAL)
    // output world normal
    outputNormal = half4(n.xyz,smoothness*_MRTSmoothness);
#endif

#if defined(OUTPUT_MOTION)
    // output motion
    outputMotionVectors = CALC_MOTION_VECTORS(i);
#endif    

#if defined(OUTPUT_WORLD_POS)
    outputPos = float4(worldPos,1);
#endif

//-------- clip
    #if defined(ALPHA_TEST)
        clip(alpha - _Cutoff);
    #endif
//-------- lod group fading
    #if defined(LOD_FADE_CROSSFADE)
        ClipLOD(i.vertex.xy);
    #endif
    
//--------- lighting
    float specTerm = 0;

    if(_SpecularOn){
        // if(_PbrMode == 0){
        #if defined(_PBRMODE_PBR)
            specTerm = MinimalistCookTorrance(nh,lh,a,a2);
            // specTerm = D_GGXNoPI(nh,a2);
        // }else if(_PbrMode == 1){
        #elif defined(_PBRMODE_ANISO)
            float3 t = tangent;//(cross(n,float3(0,1,0)));
            float3 b = binormal;//cross(t,n);
            if(_CalcTangent){
                t = cross(n,float3(0,1,0));
                b = cross(t,n);
            }
            b += n * _AnisoShift;
            
            float th = dot(t,h);
            float bh = dot(b,h);
            float anisoRough = _AnisoRough + 0.5;
            specTerm = D_GGXAnisoNoPI(th,bh,nh,anisoRough,1 - anisoRough);
            specTerm = clamp(specTerm,0,100);
        #elif defined(_PBRMODE_CHARLIE)
        // }else if(_PbrMode == 2){
            specTerm = CharlieD(nh, roughness);
            specTerm = smoothstep(_ClothRange.x,_ClothRange.y,specTerm);
            specTerm = clamp(specTerm,0,100);
            // return specTerm* albedo.xyzx;
        // }
        #elif defined(_PBRMODE_GGX)
            specTerm = D_GGXTerm(nh,a2);
            specTerm = clamp(specTerm,0,100);
        #endif
        // will show strange color, exceed range
    }


    float3 directColor = (diffColor + specColor * specTerm) * radiance;
// return directColor.xyzx;
//------- gi
    //--- custom ibl
    #if defined(_IBL_ON)
        #define IBL_CUBE _IBLCube
        #define IBL_CUBE_SAMPLER sampler_IBLCube
        #define IBL_HDR _IBLCube_HDR    
    #else
        #define IBL_CUBE unity_SpecCube0
        #define IBL_CUBE_SAMPLER samplerunity_SpecCube0
        #define IBL_HDR unity_SpecCube0_HDR
    #endif

    float4 planarReflectTex = 0;
    #if defined(_PLANAR_REFLECTION_ON)
        screenUV.x = _PlanarReflectionReverseU ? 1 - screenUV.x: screenUV.x;
        screenUV.y = _PlanarReflectionReverseV ? 1 - screenUV.y : screenUV.y;
        half lod = CalcLOD(roughness);
        planarReflectTex = tex2Dlod(_ReflectionTexture,half4(screenUV,0,lod));
    #endif
    float3 giColor = 0;
    float3 giDiff = CalcGIDiff(normal,diffColor,lightmapUV);
    float3 giSpec = CalcGISpec(IBL_CUBE,IBL_CUBE_SAMPLER,IBL_HDR,specColor,worldPos,n,v,_ReflectDirOffset.xyz/*reflectDirOffset*/,_EnvIntensity/*reflectIntensity*/
    ,nv,roughness,a2,smoothness,metallic,half2(0,1),_FresnelIntensity,planarReflectTex,0,0,_BoxProjectionOn);
    
    giColor = (giDiff * _LightmapColor.xyz + giSpec) * occlusion;

    float4 col = 0;
    col.rgb = directColor + giColor;

    #if defined(_ADDITIONAL_LIGHTS_ON)
        col.rgb += CalcAdditionalLights(worldPos,diffColor,specColor,n,v,a,a2,shadowMask,1,_CalcAdditionalLights,_ReceiveAdditionalLightShadow);
    #endif
//------ emission
    half3 emissionColor = 0;
    #if defined(_EMISSION)
        emissionColor += CalcEmission(tex2D(_EmissionMap,mainUV),_EmissionColor.xyz,_EmissionColor.w*_EmissionOn);
    #endif
    #if defined(_STOREY_ON)
    // if(_StoreyTilingOn)
    {
        ApplyStoreyEmission(emissionColor/**/,alpha/**/,worldPos,mainUV,_StoreyLightSwitchSpeed,_StoreyWindowInfo,_StoreyLightOpaque);
        // ApplyStoreyLineEmission(emission/**/,worldPos,input.uv.xy,input.color,nv);
    }
    #endif
    branch_if(_EmissionHeightOn)
    {
        ApplyHeightEmission(emissionColor/**/,worldPos,i.fogCoord.z/*upFaceAtten*/,_EmissionHeight.xy,_EmissionHeightColor);
    }
    col.rgb += emissionColor;

    // #if defined(_CLOUD_SHADOW_ON)
    // branch_if(_CloudShadowOn)
    // {
    //     col.xyz *= CalcCloudShadow(TEXTURE2D_ARGS(_WeatherNoiseTexture,sampler_WeatherNoiseTexture),worldPos,_CloudNoiseTilingOffset,_CloudNoiseOffsetStop,
    //     _CloudNoiseRangeMin,_CloudNoiseRangeMax,_CloudShadowColor,_CloudShadowIntensity,_CloudBaseShadowIntensity);
    // }
    // #endif

//------ fog
    // col.rgb = MixFog(col.xyz,i.fogFactor.x);
    // #endif
    float fogNoise = 0;
    #if defined(_DEPTH_FOG_NOISE_ON)
    branch_if(_FogNoiseOn)
    {
        half4 weights=float4(.5,.1,.1,.5);
        fogNoise = CalcWorldNoise(worldPos,_FogNoiseTilingOffset,-_GlobalWindDir.xyz,weights);
    }
    #endif

    BlendFogSphereKeyword(col.rgb/**/,worldPos,i.fogCoord.xy,_HeightFogOn,fogNoise,_DepthFogOn); // 2fps
    col.a = alpha;
    return col;
}

#endif //PBR_FORWARD_PASS_HLSL