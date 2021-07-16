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

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _Color;
float _NormalScale;
float _Metallic,_Smoothness,_Occlusion;
float _ClipOn;
float _Cutoff;

float _EmissionOn;
float4 _EmissionColor;

float _AlphaPremultiply;
float _IsReceiveShadow;
float _LightmapSH;

float _IBLOn;
float4 _ReflectDirOffset;

float _CustomLightOn;
float4 _CustomLightDir;
float4 _CustomLightColor;

float _WindOn;
float4 _WindAnimParam;
float4 _WindDir;
float4 _GlobalWindDir; /*global wind direction controlled by script*/
CBUFFER_END

// dots instancing
#if defined(UNITY_DOTS_INSTANCING_ENABLED)
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float4,_Color)
    UNITY_DOTS_INSTANCED_PROP(float,_NormalScale)
    UNITY_DOTS_INSTANCED_PROP(float,_Metallic)
    UNITY_DOTS_INSTANCED_PROP(float,_Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float,_Occlusion)
    UNITY_DOTS_INSTANCED_PROP(float,_ClipOn)
    UNITY_DOTS_INSTANCED_PROP(float,_Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float,_EmissionOn)
    UNITY_DOTS_INSTANCED_PROP(float4,_EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float,_AlphaPremultiply)
    UNITY_DOTS_INSTANCED_PROP(float,_IsReceiveShadow)
    UNITY_DOTS_INSTANCED_PROP(float,_LightmapSH)

    UNITY_DOTS_INSTANCED_PROP(float,_IBLOn)
    UNITY_DOTS_INSTANCED_PROP(float4,_ReflectDirOffset)
    UNITY_DOTS_INSTANCED_PROP(float,_CustomLightOn)
    UNITY_DOTS_INSTANCED_PROP(float4,_CustomLightDir)
    UNITY_DOTS_INSTANCED_PROP(float4,_CustomLightColor)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Color UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4,Metadata__Color)
#define _NormalScale UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__NormalScale)
#define _Metallic UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__Metallic)
#define _Smoothness UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__Smoothness)
#define _Occlusion UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__Occlusion)

#define _ClipOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__ClipOn)
#define _Cutoff UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__Cutoff)
#define _EmissionOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__EmissionOn)
#define _EmissionColor UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4,Metadata__EmissionColor)
#define _AlphaPremultiply UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__AlphaPremultiply)
#define _IsReceiveShadow UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__IsReceiveShadow)
#define _LightmapSH UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__LightmapSH)
#define _IBLOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__IBLOnH)
#define _ReflectDirOffset UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__ReflectDirOffset)
#define _CustomLightOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__CustomLightOn)
#define _CustomLightDir UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__CustomLightDir)
#define _CustomLightColor UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__CustomLightColor)
#endif

TEXTURE2D(_MetallicMask); SAMPLER(sampler_MetallicMask);
TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
TEXTURE2D(_MetallicMaskMap); SAMPLER(sampler_MetallicMaskMap);
TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
TEXTURECUBE(_IBLCube); SAMPLER(sampler_IBLCube);


void CalcAlbedo(TEXTURE2D_PARAM(mao,sampler_Map),float2 uv,float4 color,float cutoff,bool isClipOn,out float3 albedo,out float alpha ){
    float4 c = SAMPLE_TEXTURE2D(mao,sampler_Map,uv) * color;
    albedo = c.rgb;
    alpha = c.a;
    if(isClipOn)
        clip(alpha - cutoff);
}

float3 CalcNormal(float2 uv,TEXTURE2D_PARAM(normalMap,sampler_normalMap),float scale){
    float4 c = SAMPLE_TEXTURE2D(normalMap,sampler_normalMap,uv);
    float3 n = UnpackNormalScale(c,scale);
    return n;
}

float3 CalcEmission(float2 uv,TEXTURE2D_PARAM(map,sampler_map),float3 emissionColor,float isEmissionOn){
    if(isEmissionOn)
        return SAMPLE_TEXTURE2D(map,sampler_map,uv).xyz * emissionColor;
    return 0;
}

void InitSurfaceData(float2 uv,inout SurfaceData data){
    // float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,uv);
    // data.alpha = CalcAlpha(baseMap.w,_Color.a,_Cutoff,_ClipOn);
    // data.albedo = baseMap.xyz * _Color.xyz;
    CalcAlbedo(_BaseMap,sampler_BaseMap,uv,_Color,_Cutoff,_ClipOn,data.albedo/*out*/,data.alpha/*out*/);

    float3 metallicMask = SAMPLE_TEXTURE2D(_MetallicMaskMap,sampler_MetallicMaskMap,uv);
    data.metallic = metallicMask.x * _Metallic;
    data.smoothness = metallicMask.y * _Smoothness;
    data.occlusion = lerp(1,metallicMask.z,_Occlusion);

    data.normalTS = CalcNormal(uv,_NormalMap,sampler_NormalMap,_NormalScale);
    data.emission = CalcEmission(uv,_EmissionMap,sampler_EmissionMap,_EmissionColor,_EmissionOn);
    data.specular = (float3)0;
    data.clearCoatMask = 0;
    data.clearCoatSmoothness =1;
}

void InitSurfaceInputData(float2 uv,inout SurfaceInputData data){
    InitSurfaceData(uv,data.surfaceData /*inout*/);
    data.isAlphaPremultiply = _AlphaPremultiply;
    data.isReceiveShadow = _IsReceiveShadow && _MainLightShadowOn;
    data.lightmapSH = _LightmapSH;
}

#endif //POWER_LIT_INPUT_HLSL