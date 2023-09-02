#if !defined(POWER_LIT_INPUT_HLSL)
#define POWER_LIT_INPUT_HLSL
// in srp batcher, wanna use instanced, uncomment this
// #define UnityPerMaterial UnityPerMaterial_

#include "PowerLitCommon.hlsl"

TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
TEXTURE2D(_MetallicMaskMap); SAMPLER(sampler_MetallicMaskMap);
TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
TEXTURECUBE(_IBLCube); SAMPLER(sampler_IBLCube);

TEXTURE2D(_ReflectionTexture);SAMPLER(sampler_ReflectionTexture); // planer reflection camera, use screenUV
TEXTURE2D(_ParallaxMap);SAMPLER(sampler_ParallaxMap);
TEXTURE2D(_RippleTex);SAMPLER(sampler_RippleTex);
TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D(_CameraOpaqueTexture);SAMPLER(sampler_CameraOpaqueTexture);

// TEXTURECUBE(_RainCube);SAMPLER(sampler_RainCube);
TEXTURE2D(_StoreyLineNoiseMap);SAMPLER(sampler_StoreyLineNoiseMap);
TEXTURE2D(_DetailPBRMaskMap);SAMPLER(sampler_DetailPBRMaskMap);
TEXTURE2D(_WeatherNoiseTexture);SAMPLER(sampler_WeatherNoiseTexture);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
//--------------------------------- Main
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_Color)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_NormalMap_ST)

    UNITY_DEFINE_INSTANCED_PROP(half ,_NormalScale)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Metallic)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Smoothness)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Occlusion)
    UNITY_DEFINE_INSTANCED_PROP(half ,_InvertSmoothnessOn)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_MetallicChannel)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_SmoothnessChannel)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_OcclusionChannel)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_ClipOn) // to UNITY_DEFINE_INSTANCED_PROP(keyword ,_ALPHATEST_ON)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Cutoff)
//--------------------------------- Emission
    // UNITY_DEFINE_INSTANCED_PROP(half ,_EmissionOn) // to UNITY_DEFINE_INSTANCED_PROP(keyword ,_EMISSION)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_EmissionColor)
    
    UNITY_DEFINE_INSTANCED_PROP(half ,_EmissionHeightOn)
    UNITY_DEFINE_INSTANCED_PROP(half2, _EmissionHeight)
    UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionHeightColor)
    UNITY_DEFINE_INSTANCED_PROP(half, _EmissionHeightColorNormalAttenOn)

    // UNITY_DEFINE_INSTANCED_PROP(half, _EmissionScanLineOn)
    // UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionScanLineColor)
    // UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionScanLineMin)
    // UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionScanLineMax)
    // UNITY_DEFINE_INSTANCED_PROP(half, _EmissionScanLineRate)
    

    UNITY_DEFINE_INSTANCED_PROP(half ,_AlphaPremultiply) // ,_ALPHA_PREMULTIPLY_ON)

    // UNITY_DEFINE_INSTANCED_PROP(half ,_IsReceiveShadowOff) // to UNITY_DEFINE_INSTANCED_PROP(keyword ,_RECEIVE_SHADOWS_OFF)
    UNITY_DEFINE_INSTANCED_PROP(half,_GIApplyMainLightShadow) 
    UNITY_DEFINE_INSTANCED_PROP(half,_ScreenShadowOn)
//--------------------------------- IBL
    // UNITY_DEFINE_INSTANCED_PROP(half ,_IBLOn) //,_IBL_ON)
    UNITY_DEFINE_INSTANCED_PROP(half ,_EnvIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_IBLMaskMainTexA)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_ReflectDirOffset)
    UNITY_DEFINE_INSTANCED_PROP(half,_ReflectMode)
    
//--------------------------------- Custom Light
    UNITY_DEFINE_INSTANCED_PROP(half ,_CustomLightOn) //,_CUSTOM_LIGHT_ON)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_CustomLightDir)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_CustomLightColor)
    UNITY_DEFINE_INSTANCED_PROP(half,_CustomLightColorUsage)
    UNITY_DEFINE_INSTANCED_PROP(half ,_FresnelIntensity)
//--------------------------------- lightmap
    UNITY_DEFINE_INSTANCED_PROP(half ,_LightmapSHAdditional)
    UNITY_DEFINE_INSTANCED_PROP(half ,_LMSaturateAdditional)
    UNITY_DEFINE_INSTANCED_PROP(half ,_LMIntensityAdditional)    
//--------------------------------- Wind
    UNITY_DEFINE_INSTANCED_PROP(half ,_WindOn)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_WindAnimParam)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_WindDir)
    UNITY_DEFINE_INSTANCED_PROP(half ,_WindSpeed)
//--------------------------------- Plannar Reflection
    // UNITY_DEFINE_INSTANCED_PROP(half ,_PlanarReflectionOn) // ,_PLANAR_REFLECTION_ON)
    UNITY_DEFINE_INSTANCED_PROP(half ,_PlanarReflectionReverseUVX)
//--------------------------------- Rain
    UNITY_DEFINE_INSTANCED_PROP(half ,_SnowOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_SnowIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ApplyEdgeOn)
//--------------------------------- Fog
    UNITY_DEFINE_INSTANCED_PROP(half ,_FogOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_FogNoiseOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_DepthFogOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_HeightFogOn)
//--------------------------------- Parallax
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxOn) // to UNITY_DEFINE_INSTANCED_PROP(keyword ,_PARALLAX)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxIterate)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxInVSOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxHeight)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxMapChannel)
//--------------------------------- Rain
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainOn)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_RippleTex_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_RippleOffsetAutoStop)
    UNITY_DEFINE_INSTANCED_PROP(half,_RippleAlbedoIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RippleSpeed)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RippleIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RippleBlendNormalOn)

    UNITY_DEFINE_INSTANCED_PROP(half4 ,_RainColor)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainSmoothness)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainMetallic)
    UNITY_DEFINE_INSTANCED_PROP(half,_RainIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainHeight)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainSlopeAtten)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainMaskFrom)
    
    
    // UNITY_DEFINE_INSTANCED_PROP(half,_RainReflectOn)
    UNITY_DEFINE_INSTANCED_PROP(half3 ,_RainReflectDirOffset)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_RainReflectTilingOffset)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainReflectIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainFlowIntensity)
    

    UNITY_DEFINE_INSTANCED_PROP(half ,_SurfaceDepth)
    UNITY_DEFINE_INSTANCED_PROP(half ,_SurfaceBelowOn)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_BelowColor)

    UNITY_DEFINE_INSTANCED_PROP(half ,_StoreyTilingOn)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_StoreyWindowInfo)
    UNITY_DEFINE_INSTANCED_PROP(half,_StoreyLightSwitchSpeed)
    UNITY_DEFINE_INSTANCED_PROP(half,_StoreyHeight)
    UNITY_DEFINE_INSTANCED_PROP(half,_StoreyLineOn)
    
    UNITY_DEFINE_INSTANCED_PROP(half4,_StoreyLineColor)
    UNITY_DEFINE_INSTANCED_PROP(half,_StoreyLightOpaque)
// detail
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailUVUseWorldPos)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailWorldPlaneMode)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailWorldPosTriplanar)
    
    UNITY_DEFINE_INSTANCED_PROP(half4,_DetailPBRMaskMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPBRMetallic)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPBRSmoothness)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPBROcclusion)
    
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPbrMaskApplyMetallic)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPbrMaskApplySmoothness)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPbrMaskApplyOcclusion)
    UNITY_DEFINE_INSTANCED_PROP(half4,_IBLCube_HDR)

    UNITY_DEFINE_INSTANCED_PROP(half,_BoxProjectionOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_CloudShadowOn)
    UNITY_DEFINE_INSTANCED_PROP(half4,_CloudShadowIntensityInfo)
    UNITY_DEFINE_INSTANCED_PROP(half4,_CloudShadowTilingOffset)
    UNITY_DEFINE_INSTANCED_PROP(half4,_CloudShadowColor)
    
    
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)


/**
    Weather vars
*/
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

//--------------------------------- Main
    #define _BaseMap_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BaseMap_ST)
    #define _Color UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Color)
    #define _NormalMap_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_NormalMap_ST)
    
    #define _NormalScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_NormalScale)
    #define _Metallic UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Metallic)
    #define _Smoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Smoothness)
    #define _Occlusion UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Occlusion)
    #define _InvertSmoothnessOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_InvertSmoothnessOn)
    #define _MetallicChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MetallicChannel)
    #define _SmoothnessChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SmoothnessChannel)
    #define _OcclusionChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OcclusionChannel)
    // #define _ClipOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ClipOn) // to keyword _ALPHATEST_ON
    #define _Cutoff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Cutoff)
//--------------------------------- Emission
    // #define _EmissionOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionOn) // to keyword _EMISSION
    #define _EmissionColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionColor)

    #define _EmissionHeightOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionHeightOn)
    #define _EmissionHeight UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionHeight)
    #define _EmissionHeightColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionHeightColor)
    #define _EmissionHeightColorNormalAttenOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionHeightColorNormalAttenOn)

    #define _EmissionScanLineOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineOn)
    // #define _EmissionScanLineColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineColor)
    // #define _EmissionScanLineMin UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineMin)
    // #define _EmissionScanLineMax UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineMax)
    // #define _EmissionScanLineRate UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineRate)

    #define _AlphaPremultiply UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_AlphaPremultiply) // _ALPHA_PREMULTIPLY_ON

    // #define _IsReceiveShadowOff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_IsReceiveShadowOff) // to keyword _RECEIVE_SHADOWS_OFF
    #define _GIApplyMainLightShadow UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_GIApplyMainLightShadow) 
    #define _ScreenShadowOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ScreenShadowOn) 
    
//--------------------------------- IBL
    // #define _IBLOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_IBLOn) //_IBL_ON
    #define _EnvIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvIntensity)
    #define _IBLMaskMainTexA UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_IBLMaskMainTexA)
    #define _ReflectDirOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ReflectDirOffset)
    #define _ReflectMode UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ReflectMode)
//--------------------------------- Custom Light
    #define _CustomLightOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightOn) //_CUSTOM_LIGHT_ON
    #define _CustomLightDir UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightDir)
    #define _CustomLightColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightColor)
    #define _CustomLightColorUsage UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightColorUsage)
    #define _FresnelIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FresnelIntensity)
//--------------------------------- lightmap
    #define _LightmapSHAdditional UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_LightmapSHAdditional)
    #define _LMSaturateAdditional UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_LMSaturateAdditional)
    #define _LMIntensityAdditional UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_LMIntensityAdditional)    
//--------------------------------- Wind
    #define _WindOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WindOn)
    #define _WindAnimParam UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WindAnimParam)
    #define _WindDir UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WindDir)
    #define _WindSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WindSpeed)
//--------------------------------- Plannar Reflection
    // #define _PlanarReflectionOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PlanarReflectionOn) // _PLANAR_REFLECTION_ON
    #define _PlanarReflectionReverseUVX UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PlanarReflectionReverseUVX)
//--------------------------------- Snow
    #define _SnowOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SnowOn)
    #define _SnowIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SnowIntensity)
    #define _ApplyEdgeOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ApplyEdgeOn)
//--------------------------------- Fog
    #define _FogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FogOn)
    #define _FogNoiseOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FogNoiseOn)
    #define _DepthFogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DepthFogOn)
    #define _HeightFogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_HeightFogOn)
//--------------------------------- Parallax
    // #define _ParallaxOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxOn) // to keyword _PARALLAX
    #define _ParallaxIterate UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxIterate)
    #define _ParallaxInVSOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxInVSOn)
    #define _ParallaxHeight UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxHeight)
    #define _ParallaxMapChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxMapChannel)
//--------------------------------- Rain
    #define _RainOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainOn)
    #define _RippleTex_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RippleTex_ST)
    #define _RippleOffsetAutoStop UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RippleOffsetAutoStop)
    #define _RippleAlbedoIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RippleAlbedoIntensity)
    
    #define _RippleSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RippleSpeed)
    #define _RainSlopeAtten UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainSlopeAtten)
    #define _RainMaskFrom UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainMaskFrom)
    
    #define _RippleIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RippleIntensity)
    #define _RippleBlendNormalOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RippleBlendNormalOn)
//--------------------------------- Rain reflection
    #define _RainColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainColor)
    #define _RainSmoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainSmoothness)
    #define _RainMetallic UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainMetallic)
    // #define _RainReflectOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainReflectOn)
    #define _RainReflectDirOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainReflectDirOffset)
    #define _RainReflectTilingOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainReflectTilingOffset)
    #define _RainHeight UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainHeight)
    #define _RainIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainIntensity)
    #define _RainReflectIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainReflectIntensity)
    #define _RainFlowIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainFlowIntensity)
    
    #define _SurfaceDepth UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SurfaceDepth)
    #define _SurfaceBelowOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SurfaceBelowOn)
    #define _BelowColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BelowColor)
//--------------------------------- Storey
    #define _StoreyTilingOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyTilingOn)
    #define _StoreyWindowInfo UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyWindowInfo)
    #define _StoreyLightSwitchSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyLightSwitchSpeed)
    #define _StoreyHeight UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyHeight)
    #define _StoreyLineColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyLineColor)

    #define _StoreyLineOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyLineOn)
    #define _StoreyLightOpaque UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyLightOpaque)
//--------------------------------- Details    
    #define _DetailUVUseWorldPos UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailUVUseWorldPos)
    #define _DetailWorldPlaneMode UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailWorldPlaneMode)
    #define _DetailWorldPosTriplanar UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailWorldPosTriplanar)
    
    #define _DetailPBRMaskMap_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailPBRMaskMap_ST)
    #define _DetailPBRMetallic UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailPBRMetallic)
    #define _DetailPBRSmoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailPBRSmoothness)
    #define _DetailPBROcclusion UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailPBROcclusion)
    
    #define _DetailPbrMaskApplyMetallic UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailPbrMaskApplyMetallic)
    #define _DetailPbrMaskApplySmoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailPbrMaskApplySmoothness)
    #define _DetailPbrMaskApplyOcclusion UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DetailPbrMaskApplyOcclusion)
    #define _IBLCube_HDR UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_IBLCube_HDR)
    #define _BoxProjectionOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BoxProjectionOn)
    #define _CloudShadowOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CloudShadowOn)
    #define _CloudShadowTilingOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CloudShadowTilingOffset)
    #define _CloudShadowIntensityInfo UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CloudShadowIntensityInfo)
    #define _CloudShadowColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CloudShadowColor)
    
/**
    Global Variables Emission Scanline
*/    

    half4 _EmissionScanLineColor;
    half3 _EmissionScanLineMin;
    half3 _EmissionScanLineMax;
    half4 _EmissionScanLineRange_Rate;
    half _ScanLineAxis;
#endif //POWER_LIT_INPUT_HLSL