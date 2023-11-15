#if !defined(PBR_FORWARD_PASS_HLSL)
#define PBR_FORWARD_PASS_HLSL

#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/Lib/BSDF.hlsl"
#include "../../PowerShaderLib/Lib/Colors.hlsl"
#include "../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../PowerShaderLib/URPLib/Lighting.hlsl"

#include "../../PowerShaderLib/Lib/NatureLib.hlsl"
#include "../../PowerShaderLib/Lib/WeatherNoiseTexture.hlsl"
#include "../../PowerShaderLib/URPLib/URP_MotionVectors.hlsl"

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
    float4 fogCoord:TEXCOORD5;
    // motion vectors
    DECLARE_MOTION_VS_OUTPUT(6,7);
    float4 color:COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f vert (appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);

    float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
    float3 worldNormal = TransformObjectToWorldNormal(v.normal);
    float3 worldTangent = TransformObjectToWorldDir(v.tangent.xyz);

    float4 attenParam = v.color.x; // vertex color atten
    #if defined(_WIND_ON)
    branch_if(IsWindOn())
    {
        worldPos = WindAnimationVertex(worldPos,v.vertex.xyz,worldNormal,attenParam * _WindAnimParam, _WindDir,_WindSpeed).xyz;
    }
    #endif

    o.vertex = UnityWorldToClipPos(worldPos);
    o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
    o.uv.zw = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;

    TANGENT_SPACE_COMBINE_WORLD(worldPos,worldNormal,float4(worldTangent,v.tangent.w),o/**/);
    // o.shadowCoord = TransformWorldToShadowCoord(worldPos);
    o.fogCoord.xy = CalcFogFactor(p.xyz);

    o.color = v.color;

    CALC_MOTION_POSITIONS(v.prevPos,v.vertex,o,o.vertex);
    return o;
}

float4 frag (v2f i,out float4 outputNormal:SV_TARGET1,out float4 outputMotionVectors:SV_TARGET2) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);

    TANGENT_SPACE_SPLIT(i);

    float2 mainUV = i.uv.xy;
    float2 lightmapUV = i.uv.zw;
    float2 screenUV = i.vertex.xy/_ScaledScreenParams.xy;
//---------- rain

    //========  rain 1 input.uv apply rain flow
    #if defined(_RAIN_ON)
    float rainIntensity = _GlobalRainIntensity * _RainIntensity;
    float rainNoise = 0;
    float rainAtten = 0;
    branch_if(IsRainOn())
    {
        // flow atten
        rainAtten = GetRainFlowAtten(worldPos,normal,rainIntensity,_RainSlopeAtten,_RainHeight);
        mainUV += GetRainFlowUVOffset(rainNoise/**/,rainAtten,worldPos,_RainFlowTilingOffset,_RainFlowIntensity);
    }
    #endif
//-------- albedo
    float4 mainTex = tex2D(_MainTex, mainUV) * _Color;
    float3 albedo = mainTex.xyz;
    albedo *= _AlbedoMulVertexColor ? i.color.xyz : 1;
    float alpha = mainTex.w;

//---------- pbrMask
    float4 pbrMask = tex2D(_PbrMask,mainUV);
    float metallic = 0;
    float smoothness =0;
    float occlusion =0;
    SplitPbrMaskTexture(metallic/**/,smoothness/**/,occlusion/**/,pbrMask,int3(0,1,2),float3(_Metallic,_Smoothness,_Occlusion),false);

//---------- roughness
    float roughness = 0;
    float a = 0;
    float a2 = 0;
    CalcRoughness(roughness/**/,a/**/,a2/**/,smoothness);

    float3 tn = UnpackNormalScale(tex2D(_NormalMap,mainUV),_NormalScale);
//-------- rain ripple 
    #if defined(_RAIN_ON)
    branch_if(IsRainOn() && _RippleIntensity)
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
        ApplyRainPbr(albedo,metallic,smoothness,_RainColor,_RainMetallic,_RainSmoothness,rainIntensity);
    }
    #endif

//-------- lighting prepare 
    float3 n = normalize(TangentToWorld(tn,i.tSpace0,i.tSpace1,i.tSpace2));

    float3 l = (_MainLightPosition.xyz);
    float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
    float3 h = normalize(l+v);
    
    float lh = saturate(dot(l,h));
    float nh = saturate(dot(n,h));
    float nl = saturate(dot(n,l));

    float nv = saturate(dot(n,v));
// return v.xyzx;

    float4 shadowMask = SampleShadowMask(i.uv.zw);
    // return shadowMask;
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    float shadowAtten = CalcShadow(shadowCoord,worldPos,shadowMask,_MainLightShadowSoftScale);
    float distanceAtten = unity_LightData.z;
    float3 radiance = _MainLightColor.xyz * (nl * shadowAtten * distanceAtten);

    // output world normal
    outputNormal = n.xyzx;
    // output motion
    outputMotionVectors = CALC_MOTION_VECTORS(i);

//-------- snow
    #if defined(_SNOW_ON)
    branch_if(IsSnowOn())
    {
        albedo = MixSnow(albedo,1,_SnowIntensity,normal,_ApplyEdgeOn);
    }
    #endif

//-------- clip
    #if defined(ALPHA_TEST)
        clip(alpha - _Cutoff);
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

    float3 specColor = lerp(0.04,albedo,metallic);
    // if(_TFOn)
    // {
    //     float3 thinFilm = ThinFilm(1- nv,_TFScale,_TFOffset,_TFSaturate,_TFBrightness);
    //     specColor = (specColor+1) * thinFilm;
    // }
    
    float3 diffColor = albedo.xyz * (1- metallic);
    float3 directColor = (diffColor + specColor * specTerm) * radiance;
// return directColor.xyzx;
//------- gi
    float4 planarReflectTex = 0;
    #if defined(_PLANAR_REFLECTION_ON)
        planarReflectTex = tex2D(_ReflectionTexture,screenUV);
    #endif
    float3 giColor = 0;
    float3 giDiff = CalcGIDiff(normal,diffColor,lightmapUV);
    float3 giSpec = CalcGISpec(unity_SpecCube0,samplerunity_SpecCube0,unity_SpecCube0_HDR,specColor,worldPos,n,v,0/*reflectDirOffset*/,1/*reflectIntensity*/
    ,nv,roughness,a2,smoothness,metallic,half2(0,1),_FresnelIntensity,planarReflectTex);

    giColor = (giDiff + giSpec) * occlusion;

    float4 col = 0;
    col.rgb = directColor + giColor;

    #if defined(_ADDITIONAL_LIGHTS_ON)
        col.rgb += CalcAdditionalLights(worldPos,diffColor,specColor,n,v,a,a2,shadowMask);
    #endif
//------ emission
    #if defined(_EMISSION)
        col.rgb += CalcEmission(tex2D(_EmissionMap,mainUV),_EmissionColor.xyz,_EmissionColor.w);
    #endif
//------ fog
    // col.rgb = MixFog(col.xyz,i.fogFactor.x);
    BlendFogSphereKeyword(col.rgb/**/,worldPos,i.fogCoord.xy,_HeightFogOn,_FogNoiseOn,_DepthFogOn); // 2fps
    col.a = alpha;
    return col;
}

#endif //PBR_FORWARD_PASS_HLSL