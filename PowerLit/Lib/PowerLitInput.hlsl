#if !defined(POWER_LIT_INPUT_HLSL)
#define POWER_LIT_INPUT_HLSL

#include "PowerLitCommon.hlsl"

TEXTURE2D(_MetallicMask); SAMPLER(sampler_MetallicMask);
TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
TEXTURE2D(_MetallicMaskMap); SAMPLER(sampler_MetallicMaskMap);
TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);

TEXTURECUBE(_IBLCube); SAMPLER(sampler_IBLCube);
TEXTURE2D(_ReflectionTex);SAMPLER(sampler_ReflectionTex); // planer reflection camera, use screenUV
TEXTURE2D(_ParallaxMap);SAMPLER(sampler_ParallaxMap);
TEXTURE2D(_RippleTex);SAMPLER(sampler_RippleTex);
TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);

TEXTURE2D(_CameraOpaqueTexture);SAMPLER(sampler_CameraOpaqueTexture);
TEXTURECUBE(_RainCube);SAMPLER(sampler_RainCube);


#if !defined(INSTANCING_ON) || !defined(DOTS_INSTANCING_ON)
CBUFFER_START(UnityPerMaterial)
//--------------------------------- Main
    half4 _BaseMap_ST;
    half4 _Color;
    half4 _NormalMap_ST;
    half _NormalScale;
    half _Metallic,_Smoothness,_Occlusion;
    int _MetallicChannel,_SmoothnessChannel,_OcclusionChannel;
    // half _ClipOn; // to keyword _ALPHATEST_ON
    half _Cutoff;
//--------------------------------- Emission
    // half _EmissionOn; // to keyword _EMISSION
    half4 _EmissionColor;

    // half _AlphaPremultiply; // _ALPHA_PREMULTIPLY_ON
    // half _IsReceiveShadowOn; // to keyword _RECEIVE_SHADOWS_OFF
//--------------------------------- IBL
    // half _IBLOn; //_IBL_ON
    half _EnvIntensity;
    half _IBLMaskMainTexA;
    half4 _ReflectDirOffset;
//--------------------------------- Custom Light
    // half _CustomLightOn; //_CUSTOM_LIGHT_ON
    half4 _CustomLightDir;
    half4 _CustomLightColor;

    half _FresnelIntensity;
//--------------------------------- lightmap
    half _LightmapSHAdditional;
    half _LMSaturateAdditional;
    half _LMIntensityAdditional;    
//--------------------------------- Wind
    half _WindOn;
    half4 _WindAnimParam;
    half4 _WindDir;
    half _WindSpeed;
//--------------------------------- Plannar Reflection
    // half _PlanarReflectionOn; // _PLANAR_REFLECTION_ON
//--------------------------------- Rain
    half _SnowOn;
    half _SnowIntensity;
    half _ApplyEdgeOn;
//--------------------------------- Fog
    half _FogOn;
    half _FogNoiseOn;
//--------------------------------- Parallax
    // half _ParallaxOn; // to keyword _PARALLAX
    half _ParallaxHeight;
    int _ParallaxMapChannel;
//--------------------------------- Rain
    int _RainOn;
    half4 _RippleTex_ST;
    half _RippleSpeed;
    half _RainSlopeAtten;
    half _RippleIntensity;
    half _RippleBlendNormalOn;

    half4 _RainColor;
    half _RainSmoothness,_RainMetallic;
    half4 _RainCube_HDR;
    half4 _RainCube_ST;
    half3 _RainReflectDirOffset;
    half _RainHeight;
    half _RainReflectIntensity;
    half _SurfaceDepth;
    half4 _BelowColor;
CBUFFER_END

#define IsRainOn() (_IsGlobalRainOn && _RainOn)
#define IsSnowOn() (_IsGlobalSnowOn && _SnowOn)
#define IsWindOn() (_IsGlobalWindOn && _WindOn)

// #if (SHADER_LIBRARY_VERSION_MAJOR < 12)
// this block must define in UnityPerDraw cbuffer, change UnityInput.hlsl
// half4 unity_SpecCube0_BoxMax;          // w contains the blend distance
// half4 unity_SpecCube0_BoxMin;          // w contains the lerp value
// half4 unity_SpecCube0_ProbePosition;   // w is set to 1 for box projection
// half4 unity_SpecCube1_BoxMax;          // w contains the blend distance
// half4 unity_SpecCube1_BoxMin;          // w contains the sign of (SpecCube0.importance - SpecCube1.importance)
// half4 unity_SpecCube1_ProbePosition;   // w is set to 1 for box projection
// #endif

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
        UNITY_DEFINE_INSTANCED_PROP(half,_IsReceiveShadowOn)
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
    #define _IsReceiveShadowOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_IsReceiveShadowOn)
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
    UNITY_DOTS_INSTANCED_PROP(half,_IsReceiveShadowOn)
    UNITY_DOTS_INSTANCED_PROP(half,_LightmapSH)
    UNITY_DOTS_INSTANCED_PROP(half,_IBLOn)
    UNITY_DOTS_INSTANCED_PROP(half,_EnvIntensity)
    UNITY_DOTS_INSTANCED_PROP(half,_IBLMaskMainTexA)
    UNITY_DOTS_INSTANCED_PROP(half4,_ReflectDirOffset)
    UNITY_DOTS_INSTANCED_PROP(half,_CustomLightOn)
    UNITY_DOTS_INSTANCED_PROP(half4,_CustomLightDir)
    UNITY_DOTS_INSTANCED_PROP(half4,_CustomLightColor)
    UNITY_DOTS_INSTANCED_PROP(half,_WindOn)
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
#define _IsReceiveShadowOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half,Metadata__IsReceiveShadow)
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

#endif //POWER_LIT_INPUT_HLSL