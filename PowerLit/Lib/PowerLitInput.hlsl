#if !defined(POWER_LIT_INPUT_HLSL)
#define POWER_LIT_INPUT_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "PowerSurfaceInputData.hlsl"
#include "NatureLib.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "PowerLitCommon.hlsl"

#if !defined(INSTANCING_ON) || !defined(DOTS_INSTANCING_ON)
CBUFFER_START(UnityPerMaterial)
    half4 _BaseMap_ST;
    half4 _Color;
    half _NormalScale;
    half _Metallic,_Smoothness,_Occlusion;
    int _MetallicChannel,_SmoothnessChannel,_OcclusionChannel;
    half _ClipOn;
    half _Cutoff;

    half _EmissionOn;
    half4 _EmissionColor;

    half _AlphaPremultiply;
    half _IsReceiveShadow;

    half _LightmapSH;
    half _LMSaturate;

    half _IBLOn;
    half _EnvIntensity;
    half _IBLMaskMainTexA;
    half4 _ReflectDirOffset;

    half _CustomLightOn;
    half4 _CustomLightDir;
    half4 _CustomLightColor;

    half _FresnelIntensity;

    half _WindOn;
    half4 _WindAnimParam;
    half4 _WindDir;

    half _SnowIntensity;
    half _SphereFogOn;
    half _PlanarReflectionOn;
CBUFFER_END

float4 unity_SpecCube0_BoxMax;          // w contains the blend distance
float4 unity_SpecCube0_BoxMin;          // w contains the lerp value
float4 unity_SpecCube0_ProbePosition;   // w is set to 1 for box projection
float4 unity_SpecCube1_BoxMax;          // w contains the blend distance
float4 unity_SpecCube1_BoxMin;          // w contains the sign of (SpecCube0.importance - SpecCube1.importance)
float4 unity_SpecCube1_ProbePosition;   // w is set to 1 for box projection

#endif
/**
#if defined(INSTANCING_ON)
    UNITY_INSTANCING_BUFFER_START(PropBuffer)
        UNITY_DEFINE_INSTANCED_PROP(half4,_BaseMap_ST)
        UNITY_DEFINE_INSTANCED_PROP(half4,_Color)
        UNITY_DEFINE_INSTANCED_PROP(half,_NormalScale)
        UNITY_DEFINE_INSTANCED_PROP(half,_Metallic)
        UNITY_DEFINE_INSTANCED_PROP(half,_Smoothness)
        UNITY_DEFINE_INSTANCED_PROP(half,_Occlusion)
        UNITY_DEFINE_INSTANCED_PROP(half,_MetallicChannel)
        UNITY_DEFINE_INSTANCED_PROP(half,_SmoothnessChannel)
        UNITY_DEFINE_INSTANCED_PROP(half,_OcclusionChannel)        
        UNITY_DEFINE_INSTANCED_PROP(half,_ClipOn)
        UNITY_DEFINE_INSTANCED_PROP(half,_Cutoff)
        UNITY_DEFINE_INSTANCED_PROP(half,_EmissionOn)
        UNITY_DEFINE_INSTANCED_PROP(half4,_EmissionColor)
        UNITY_DEFINE_INSTANCED_PROP(half,_AlphaPremultiply)
        UNITY_DEFINE_INSTANCED_PROP(half,_IsReceiveShadow)
        UNITY_DEFINE_INSTANCED_PROP(half,_LightmapSH)
        UNITY_DEFINE_INSTANCED_PROP(half,_IBLOn)
        UNITY_DEFINE_INSTANCED_PROP(half,_EnvIntensity) 
        UNITY_DEFINE_INSTANCED_PROP(half,_IBLMaskMainTexA) 
        UNITY_DEFINE_INSTANCED_PROP(half4,_ReflectDirOffset)
        UNITY_DEFINE_INSTANCED_PROP(half,_CustomLightOn)
        UNITY_DEFINE_INSTANCED_PROP(half4,_CustomLightDir)
        UNITY_DEFINE_INSTANCED_PROP(half4,_CustomLightColor)
        UNITY_DEFINE_INSTANCED_PROP(half,_WindOn)
        UNITY_DEFINE_INSTANCED_PROP(half4,_WindAnimParam)
        UNITY_DEFINE_INSTANCED_PROP(half4,_WindDir)
    UNITY_INSTANCING_BUFFER_END(PropBuffer)

    #define _BaseMap_ST UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_BaseMap_ST)
    #define _Color UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Color)
    #define _NormalScale UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_NormalScale)
    #define _Metallic UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Metallic)
    #define _Smoothness UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Smoothness)
    #define _Occlusion UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Occlusion)
    #define _MetallicChannel UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_MetallicChannel)
    #define _SmoothnessChannel UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_SmoothnessChannel)
    #define _OcclusionChannel UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_OcclusionChannel)    
    #define _ClipOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_ClipOn)
    #define _Cutoff UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Cutoff)
    #define _EmissionOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_EmissionOn)
    #define _EmissionColor UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_EmissionColor)
    #define _AlphaPremultiply UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_AlphaPremultiply)
    #define _IsReceiveShadow UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_IsReceiveShadow)
    #define _LightmapSH UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_LightmapSH)
    #define _IBLOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_IBLOn)
    #define _EnvIntensity UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_EnvIntensity)
    #define _IBLMaskMainTexA UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_IBLMaskMainTexA)
    #define _ReflectDirOffset UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_ReflectDirOffset)
    #define _CustomLightOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_CustomLightOn)
    #define _CustomLightDir UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_CustomLightDir)
    #define _CustomLightColor UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_CustomLightColor)
    #define _WindOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_WindOn)
    #define _WindAnimParam UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_WindAnimParam)
    #define _WindDir UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_WindDir)
#endif


// dots instancing
#if defined(DOTS_INSTANCING_ON)
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(half4,_BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(half4,_Color)
    UNITY_DOTS_INSTANCED_PROP(half,_NormalScale)
    UNITY_DOTS_INSTANCED_PROP(half,_Metallic)
    UNITY_DOTS_INSTANCED_PROP(half,_Smoothness)
    UNITY_DOTS_INSTANCED_PROP(half,_Occlusion)
    UNITY_DOTS_INSTANCED_PROP(half,_MetallicChannel)
    UNITY_DOTS_INSTANCED_PROP(half,_SmoothnessChannel)
    UNITY_DOTS_INSTANCED_PROP(half,_OcclusionChannel)

    UNITY_DOTS_INSTANCED_PROP(half,_ClipOn)
    UNITY_DOTS_INSTANCED_PROP(half,_Cutoff)
    UNITY_DOTS_INSTANCED_PROP(half,_EmissionOn)
    UNITY_DOTS_INSTANCED_PROP(half4,_EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(half,_AlphaPremultiply)
    UNITY_DOTS_INSTANCED_PROP(half,_IsReceiveShadow)
    UNITY_DOTS_INSTANCED_PROP(half,_LightmapSH)
    UNITY_DOTS_INSTANCED_PROP(half,_IBLOn)
    UNITY_DOTS_INSTANCED_PROP(half,_EnvIntensity)
    UNITY_DOTS_INSTANCED_PROP(half,_IBLMaskMainTexA)
    UNITY_DOTS_INSTANCED_PROP(half4,_ReflectDirOffset)
    UNITY_DOTS_INSTANCED_PROP(half,_CustomLightOn)
    UNITY_DOTS_INSTANCED_PROP(half4,_CustomLightDir)
    UNITY_DOTS_INSTANCED_PROP(half4,_CustomLightColor)
    UNITY_DOTS_INSTANCED_PROP(Float,_WindOn)
    UNITY_DOTS_INSTANCED_PROP(half4,_WindAnimParam)
    UNITY_DOTS_INSTANCED_PROP(half4,_WindDir)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Color UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4,Metadata__Color)
#define _NormalScale UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__NormalScale)
#define _Metallic UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__Metallic)
#define _Smoothness UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__Smoothness)
#define _Occlusion UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__Occlusion)
#define _MetallicChannel UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__MetallicChannel)
#define _SmoothnessChannel UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__SmoothnessChannel)
#define _OcclusionChannel UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__OcclusionChannel)
#define _ClipOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__ClipOn)
#define _Cutoff UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__Cutoff)
#define _EmissionOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__EmissionOn)
#define _EmissionColor UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4,Metadata__EmissionColor)
#define _AlphaPremultiply UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__AlphaPremultiply)
#define _IsReceiveShadow UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__IsReceiveShadow)
#define _LightmapSH UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__LightmapSH)
#define _IBLOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__IBLOnH)
#define _EnvIntensity UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__EnvIntensity)
#define _IBLMaskMainTexA UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__IBLMaskMainTexA)
#define _ReflectDirOffset UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__ReflectDirOffset)
#define _CustomLightOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__CustomLightOn)
#define _CustomLightDir UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__CustomLightDir)
#define _CustomLightColor UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__CustomLightColor)
#define _WindOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__WindOn)
#define _WindAnimParam UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4,Metadata__WindAnimParam)
#define _WindDir UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4,Metadata__WindDir)
#endif
*/

TEXTURE2D(_MetallicMask); SAMPLER(sampler_MetallicMask);
TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
TEXTURE2D(_MetallicMaskMap); SAMPLER(sampler_MetallicMaskMap);
TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
TEXTURECUBE(_IBLCube); SAMPLER(sampler_IBLCube);
TEXTURE2D(_ReflectionTex);SAMPLER(sampler_ReflectionTex); // planer reflection camera, use screenUV


void CalcAlbedo(TEXTURE2D_PARAM(mao,sampler_Map),half2 uv,half4 color,half cutoff,bool isClipOn,out half3 albedo,out half alpha ){
    half4 c = SAMPLE_TEXTURE2D(mao,sampler_Map,uv) * color;
    albedo = c.rgb;
    alpha = c.a;
    if(isClipOn)
        clip(alpha - cutoff);
}

half3 CalcNormal(half2 uv,TEXTURE2D_PARAM(normalMap,sampler_normalMap),half scale){
    half4 c = SAMPLE_TEXTURE2D(normalMap,sampler_normalMap,uv);
    half3 n = UnpackNormalScale(c,scale);
    return n;
}

half3 CalcEmission(half2 uv,TEXTURE2D_PARAM(map,sampler_map),half3 emissionColor,half isEmissionOn){
    half3 emission = 0;
    if(isEmissionOn)
        emission = SAMPLE_TEXTURE2D(map,sampler_map,uv).xyz * emissionColor;
    return emission;
}

void InitSurfaceData(half2 uv,inout SurfaceData data){
    // half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,uv);
    // data.alpha = CalcAlpha(baseMap.w,_Color.a,_Cutoff,_ClipOn);
    // data.albedo = baseMap.xyz * _Color.xyz;
    CalcAlbedo(_BaseMap,sampler_BaseMap,uv,_Color,_Cutoff,_ClipOn,data.albedo/*out*/,data.alpha/*out*/);

    half4 metallicMask = SAMPLE_TEXTURE2D(_MetallicMaskMap,sampler_MetallicMaskMap,uv);
    data.metallic = metallicMask[_MetallicChannel] * _Metallic;
    data.smoothness = metallicMask[_SmoothnessChannel] * _Smoothness;
    data.occlusion = lerp(1,metallicMask[_OcclusionChannel],_Occlusion);

    data.normalTS = CalcNormal(uv,_NormalMap,sampler_NormalMap,_NormalScale);
    data.emission = CalcEmission(uv,_EmissionMap,sampler_EmissionMap,_EmissionColor.xyz,_EmissionOn);
    data.specular = (half3)0;
    data.clearCoatMask = 0;
    data.clearCoatSmoothness =1;
}

void InitSurfaceInputData(half2 uv,half4 clipPos,inout SurfaceInputData data){
    InitSurfaceData(uv,data.surfaceData /*inout*/);
    data.isAlphaPremultiply = _AlphaPremultiply;
    data.isReceiveShadow = _IsReceiveShadow && _MainLightShadowOn;
    data.lightmapSH = _LightmapSH;
    data.lmSaturate = _LMSaturate;

    
    data.screenUV = clipPos.xy/_ScreenParams.xy;
    data.screenUV.x = 1- data.screenUV.x;
}

#endif //POWER_LIT_INPUT_HLSL