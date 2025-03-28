#if !defined(POWER_LIT_FORWARD_PASS_HLSL)
#define POWER_LIT_FORWARD_PASS_HLSL

#include "PowerLitCore.hlsl"
#include "GI.hlsl"

struct Attributes{
    float4 pos:POSITION;
    float3 normal:NORMAL;
    float4 color:COLOR;
    float4 tangent:TANGENT;
    float2 uv:TEXCOORD;
    float2 uv1 :TEXCOORD1;
    // float3 prevPos:TEXCOORD4;
    DECLARE_MOTION_VS_INPUT(prevPos);
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings{
    float4 pos : SV_POSITION;
    float4 uv:TEXCOORD0; // xy : uv, zw: uv1 for lightmap uv
    // float uv1:TEXCOORD1; // sh,lightmap
    float4 tSpace0:TEXCOORD2;
    float4 tSpace1:TEXCOORD3;
    float4 tSpace2:TEXCOORD4;
    float4 bigShadowCoord_UpFaceAtten:TEXCOORD5;
    float4 shadowCoord:TEXCOORD6;
    float4 viewDirTS_NV:TEXCOORD7;
    // motion vectors
    DECLARE_MOTION_VS_OUTPUT(1,8);
    float4 vertexPos:TEXCOORD9;

    float4 color:COLOR;
    float4 fogCoord:COLOR1;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings vert(Attributes input){
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input,output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 worldPos = TransformObjectToWorld(input.pos.xyz);
    float3 worldNormal = normalize(TransformObjectToWorldNormal(input.normal));

    float4 attenParam = input.color.x; // vertex color atten
    #if defined(_WIND_ON)
    branch_if(IsWindOn())
    {
        worldPos = WindAnimationVertex(worldPos,input.pos.xyz,worldNormal,attenParam * _WindAnimParam, _WindDir,_WindSpeed).xyz;
    }

    #endif

    float sign = input.tangent.w * unity_WorldTransformParams.w;
    float3 worldTangent = normalize(TransformObjectToWorldDir(input.tangent.xyz));
    float3 worldBinormal = normalize(cross(worldNormal,worldTangent)) * sign;
    output.tSpace0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
    output.tSpace1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
    output.tSpace2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

    output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);
    
    #if defined(_STOREY_ON)
    // if(_StoreyTilingOn)
    {
        output.uv.y = WorldHeightTilingUV(worldPos,_StoreyHeight);
    }
    #endif

    // OUTPUT_LIGHTMAP_UV(input.uv1,unity_LightmapST,output.uv1);
    output.uv.zw = input.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    
    worldPos.xy += CalcCurvedPos(_WorldSpaceCameraPos,worldPos,_CurvedSidewayScale,_CurvedBackwardScale);

    float4 clipPos = TransformWorldToHClip(worldPos);

    half upFaceAtten = 1;
    // #if defined(_EMISION_HEIGHT_ON)
    branch_if(_EmissionHeightOn)
    {
    upFaceAtten = 1 - saturate(dot(worldNormal,half3(0,1,0)));
    upFaceAtten = lerp(1,upFaceAtten,_EmissionHeightColorNormalAttenOn);
    }
    // #endif

    // float3 vertexLight = VertexLighting(worldPos,worldNormal);
    float3 bigShadowCoord = TransformWorldToBigShadow(worldPos);
    output.bigShadowCoord_UpFaceAtten = float4(bigShadowCoord,upFaceAtten);
    output.pos = clipPos;
    output.shadowCoord = TransformWorldToShadowCoord(worldPos);
    output.color = attenParam;

    output.fogCoord.xy = CalcFogFactor(worldPos,clipPos.z,_HeightFogOn,_DepthFogOn);

    // vertex noise
    // #if defined(_WIND_ON)
    float2 noiseUV = worldPos.xz*0.5 + _WindDir.xz * _Time.y * (_IsGlobalWindOn?_WindSpeed:0);
    // output.fogCoord.z = unity_gradientNoise(noiseUV);
    output.fogCoord.z = SampleWeatherNoiseLOD(noiseUV,0);
    // #endif

    // branch_if(_ParallaxOn)
    float3 viewDirWS = normalize(_WorldSpaceCameraPos - worldPos);
    output.viewDirTS_NV.w = saturate(dot(viewDirWS,worldNormal));
    output.viewDirTS_NV.xyz = (float3(
        dot(worldTangent,viewDirWS),
        dot(worldBinormal,viewDirWS),
        dot(worldNormal,viewDirWS)
    ));

    #if !defined(_WIND_ON)
    CALC_MOTION_POSITIONS(input.prevPos,input.pos,output,clipPos);
    #else
    // zero motionsf
    ZERO_MOTION_POSITIONS(input.prevPos,input.pos,output,clipPos);
    #endif
    output.vertexPos = input.pos;

    return output;
}

float4 frag(Varyings input
    ,out float4 outputNormal:SV_TARGET1
    ,out float4 outputMotionVectors:SV_TARGET2
):SV_Target{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    // global vars
    float3 worldPos = float3(input.tSpace0.w,input.tSpace1.w,input.tSpace2.w);
    float3 vertexNormal = float3(input.tSpace0.z,input.tSpace1.z,input.tSpace2.z);
    float vertexNoise = input.fogCoord.z;

    float3 viewDirTS = input.viewDirTS_NV.xyz;
    float vertexNV = input.viewDirTS_NV.w;

    #if defined(_PARALLAX)
        // branch_if(! _ParallaxInVSOn)
        ApplyParallax(input.uv.xy/**/,input.viewDirTS_NV.xyz,_ParallaxHeight); // move to vs
    #endif

    //========  rain 1 input.uv apply rain flow
    #if defined(_RAIN_ON)
    float rainIntensity = _GlobalRainIntensity * _RainIntensity;
    float rainAtten = 0;
    float rainNoise = 0;
    branch_if(IsRainOn())
    {
        // flow atten
        rainAtten = GetRainFlowAtten(worldPos,vertexNormal,rainIntensity,_RainSlopeAtten,_RainHeight);
        input.uv.xy += GetRainFlowUVOffset(rainNoise/**/,rainAtten,worldPos,_RainFlowTilingOffset,_RainFlowIntensity);
    }
    #endif

//------------ uv
    float2 mainUV = input.uv.xy;
    float2 lightmapUV = input.uv.zw;
    float2 screenUV = input.pos.xy/_ScaledScreenParams.xy;

//------------ albedo
    float3 albedo = 0;
    float alpha = 1;
    CalcAlbedo(_BaseMap,sampler_BaseMap,mainUV,_Color,_Cutoff,0,_AlphaPremultiply,albedo/*out*/,alpha/*out*/);

    half4 pbrMask = SAMPLE_TEXTURE2D(_MetallicMaskMap,sampler_MetallicMaskMap,mainUV);
    float metallic = 0;
    float smoothness =0;
    float occlusion =0;

//---------- pbrMask    
    SplitPbrMaskTexture(
        metallic/**/,smoothness/**/,occlusion/**/,
        pbrMask,
        // half3(_MetallicChannel,_SmoothnessChannel,_OcclusionChannel), // gen code use dot
        half3(0,1,2),
        half3(_Metallic,_Smoothness,_Occlusion),
        _InvertSmoothnessOn
    );
    // apply detail layers
    ApplyDetails(metallic/**/,smoothness,occlusion,mainUV,worldPos,vertexNormal);

//-------- normal
    float3 tn = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,mainUV),_NormalScale);
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
        }

        // change pbr mask
        ApplyRainPbr(albedo/**/,metallic/**/,smoothness/**/,_RainColor,_RainMetallic,_RainSmoothness,rainIntensity);
    }
    #endif

    float3 n = normalize(TangentToWorld(tn,input.tSpace0,input.tSpace1,input.tSpace2));
//---------- snow    
    ApplySnow(albedo/**/,n/**/,alpha,input.vertexPos);
    
//---------- surface bedow    
    ApplySurfaceBelow(albedo/**/,worldPos);

//---------- surface color
    float3 specColor = lerp(0.04,albedo,metallic);
    float3 diffColor = albedo * (1 - metallic);    

//-------- main light
    float4 shadowMask = SampleShadowMask(lightmapUV);
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    Light mainLight = GetMainLight(shadowCoord,worldPos,shadowMask,_MainLightShadowSoftScale);
    branch_if(_CustomLightOn)
        OffsetLight(mainLight/**/,specColor/**/,_CustomLightColorUsage,_CustomLightDir.xyz,_CustomLightColor.xyz);

// float3 shadowPos = TransformWorldToBigShadow(worldPos);
    branch_if(!_BigShadowOff)
    {
        float atten = CalcBigShadowAtten(input.bigShadowCoord_UpFaceAtten.xyz,1);
        mainLight.shadowAttenuation = min(mainLight.shadowAttenuation,atten);
        // return atten;
    }

//------- mrt output    
    // output world normal
    outputNormal = half4(n.xyz,smoothness * _MRTSmoothness);
    // output motion
    outputMotionVectors = CALC_MOTION_VECTORS(input);
    
//---------- roughness
    float roughness = 0;
    float a = 0;
    float a2 = 0;
    CalcRoughness(roughness/**/,a/**/,a2/**/,smoothness);
//-------- lighting 
    float3 l = (mainLight.direction.xyz);
    float3 v = normalize(GetWorldSpaceViewDir(worldPos));
    float3 h = normalize(l+v);
    
    float lh = saturate(dot(l,h));
    float nh = saturate(dot(n,h));
    float nl = saturate(dot(n,l));
    float nv = saturate(dot(n,v));

    float3 radiance = mainLight.color * (nl * mainLight.distanceAttenuation * mainLight.shadowAttenuation);
    float specTerm = MinimalistCookTorrance(nh,lh,a,a2);

    float3 directColor = (diffColor + specColor * specTerm) * radiance;

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
        half mip = CalcLOD(roughness);
        planarReflectTex = SamplePlanarReflectionTex(screenUV,mip);
    #endif

    float3 giColor = 0;
    float3 giDiff = CalcGIDiff(n,diffColor,lightmapUV);
    float3 giSpec = CalcGISpec(IBL_CUBE,IBL_CUBE_SAMPLER,IBL_HDR,specColor,worldPos,n,v,_ReflectDirOffset.xyz/*reflectDirOffset*/,_EnvIntensity/*reflectIntensity*/
    ,nv,roughness,a2,smoothness,metallic,half2(0,1),_FresnelIntensity,planarReflectTex,viewDirTS,mainUV);
    // tint gi specular
    // giSpec = lerp(1,giSpec,alpha * _IBLMaskMainTexA);

    giColor = (giDiff * _LightmapColor.xyz + giSpec) * occlusion;

//------- finalColor
    float4 col = 0;
    col.rgb = directColor + giColor;

    #if defined(_ADDITIONAL_LIGHTS)
        col.rgb += CalcAdditionalLights(worldPos,diffColor,specColor,n,v,a,a2,shadowMask);
    #endif

//-------- emission
    float3 emission = CalcEmission(mainUV,_EmissionMap,sampler_EmissionMap);
    #if defined(_STOREY_ON)
    // if(_StoreyTilingOn)
    {
        ApplyStoreyEmission(emission/**/,alpha/**/,worldPos,input.uv.xy,_StoreyLightSwitchSpeed,_StoreyWindowInfo,_StoreyLightOpaque);
        ApplyStoreyLineEmission(emission/**/,worldPos,input.uv.xy,input.color,nv);
    }
    #endif

//  world emission
    half upFaceAtten = input.bigShadowCoord_UpFaceAtten.w;
    ApplyWorldEmission(emission/**/,worldPos,upFaceAtten);

    // branch_if(_EmissionScanLineOn)
    // {
    //     ApplyWorldEmissionScanLine(emission/**/,worldPos);
    // }
    #if defined(DEBUG_DISPLAY)
        half4 debugColor = half4(0,0,0,1);
        bool isBreak=0;
        debugColor.xyz = CalcDebugColor(
            isBreak/**/,
            albedo/**/,
            specColor/**/,
            alpha,
            metallic/**/,
            smoothness/**/,
            occlusion/**/,
            emission/**/,
            n/**/,
            tn/**/,
            screenUV,
            worldPos,
            input.tSpace0,
            input.tSpace1,
            input.tSpace2
        );
        if(isBreak)
            return debugColor;
    #endif    

    col.rgb += emission;
    col.a = alpha;
    // ApplyScreenShadow(color.xyz/**/,data.screenUV);

    // #if defined(_CLOUD_SHADOW_ON)
    // branch_if(_CloudShadowOn)
    // {
    //     col.xyz *= CalcCloudShadow(TEXTURE2D_ARGS(_WeatherNoiseTexture,sampler_WeatherNoiseTexture),worldPos,_CloudNoiseTilingOffset,_CloudNoiseOffsetStop,
    //     _CloudNoiseRangeMin,_CloudNoiseRangeMax,_CloudShadowColor,_CloudShadowIntensity,_CloudBaseShadowIntensity);
    // }
    // #endif

    ApplyFog(col/**/,worldPos,input.fogCoord.xy,upFaceAtten);
    return col;
}

#endif //POWER_LIT_FORWARD_PASS_HLSL