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
// TEXTURE2D(_ParallaxMap);SAMPLER(sampler_ParallaxMap);
TEXTURE2D(_RippleTex);SAMPLER(sampler_RippleTex);
TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D(_CameraOpaqueTexture);SAMPLER(sampler_CameraOpaqueTexture);

// TEXTURECUBE(_RainCube);SAMPLER(sampler_RainCube);
TEXTURE2D(_StoreyLineNoiseMap);SAMPLER(sampler_StoreyLineNoiseMap);
TEXTURE2D(_DetailPBRMaskMap);SAMPLER(sampler_DetailPBRMaskMap);


UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
//--------------------------------- Main
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_Color)
    UNITY_DEFINE_INSTANCED_PROP(half,_AlbedoMulVertexColor)
    
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_NormalMap_ST)

    UNITY_DEFINE_INSTANCED_PROP(half ,_Metallic)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Smoothness)
    UNITY_DEFINE_INSTANCED_PROP(half ,_MRTSmoothness)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Occlusion)
    UNITY_DEFINE_INSTANCED_PROP(half ,_InvertSmoothnessOn)

    // UNITY_DEFINE_INSTANCED_PROP(half4 ,_MSOInfo)
    
    // UNITY_DEFINE_INSTANCED_PROP(half ,_MetallicChannel)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_SmoothnessChannel)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_OcclusionChannel)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_ClipOn) // to UNITY_DEFINE_INSTANCED_PROP(keyword ,_ALPHATEST_ON)

    UNITY_DEFINE_INSTANCED_PROP(half ,_NormalScale)
    UNITY_DEFINE_INSTANCED_PROP(half ,_Cutoff)
    UNITY_DEFINE_INSTANCED_PROP(half ,_AlphaPremultiply) // ,_ALPHA_PREMULTIPLY_ON)
    UNITY_DEFINE_INSTANCED_PROP(half,_GIApplyMainLightShadow)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainLightShadowSoftScale)
    // UNITY_DEFINE_INSTANCED_PROP(half4,_NormalScale_Cutoff_AlphaPremultiply_GIApplyMainLightShadow) 
    
//--------------------------------- Emission
//#if defined(_EMISSION)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_EmissionOn) // to UNITY_DEFINE_INSTANCED_PROP(keyword ,_EMISSION)
    UNITY_DEFINE_INSTANCED_PROP(half ,_EmissionHeightOn)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_EmissionColor)
//#endif
//#if defined(_EMISSION_HEIGHT_ON)
    UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionHeightColor)
    UNITY_DEFINE_INSTANCED_PROP(half2, _EmissionHeight)
    UNITY_DEFINE_INSTANCED_PROP(half, _EmissionHeightColorNormalAttenOn)
    // UNITY_DEFINE_INSTANCED_PROP(half3, _EmissionHeight_EmissionHeightColorNormalAttenOn)
//#endif

    // UNITY_DEFINE_INSTANCED_PROP(half, _EmissionScanLineOn)
    // UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionScanLineColor)
    // UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionScanLineMin)
    // UNITY_DEFINE_INSTANCED_PROP(half4, _EmissionScanLineMax)
    // UNITY_DEFINE_INSTANCED_PROP(half, _EmissionScanLineRate)

    // UNITY_DEFINE_INSTANCED_PROP(half ,_IsReceiveShadowOff) // to UNITY_DEFINE_INSTANCED_PROP(keyword ,_RECEIVE_SHADOWS_OFF)
    UNITY_DEFINE_INSTANCED_PROP(half,_ScreenShadowOn)
//--------------------------------- IBL
    // UNITY_DEFINE_INSTANCED_PROP(half ,_IBLOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_EnvIntensity)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_IBLMaskMainTexA)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_ReflectDirOffset)
    // UNITY_DEFINE_INSTANCED_PROP(half,_InteriorMapOn)
    
//--------------------------------- Custom Light
//#if defined(_CUSTOM_LIGHT_ON)
    UNITY_DEFINE_INSTANCED_PROP(half ,_CustomLightOn) //,_CUSTOM_LIGHT_ON)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_CustomLightDir)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_CustomLightColor)
    UNITY_DEFINE_INSTANCED_PROP(half,_CustomLightColorUsage)
//#endif    
    UNITY_DEFINE_INSTANCED_PROP(half ,_FresnelIntensity)
// //--------------------------------- lightmap
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_LightmapColor)

//--------------------------------- Wind
//#if defined(_WIND_ON)
    UNITY_DEFINE_INSTANCED_PROP(half ,_WindOn)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_WindAnimParam)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_WindDir)
    UNITY_DEFINE_INSTANCED_PROP(half ,_WindSpeed)
//#endif    
//#if defined(_PLANAR_REFLECTION_ON)
//--------------------------------- Plannar Reflection
    // UNITY_DEFINE_INSTANCED_PROP(half ,_PlanarReflectionOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_PlanarReflectionReverseU)
    UNITY_DEFINE_INSTANCED_PROP(half ,_PlanarReflectionReverseV)
//#endif
//--------------------------------- snow
//#if defined(_SNOW_ON)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_SnowOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_SnowIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_SnowIntensityUseMainTexA)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ApplyEdgeOn)

    UNITY_DEFINE_INSTANCED_PROP(half ,_SnowNormalMask)
    UNITY_DEFINE_INSTANCED_PROP(half2 ,_SnowNoiseTiling)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_SnowNoiseWeights)

//#endif
//--------------------------------- Fog
    UNITY_DEFINE_INSTANCED_PROP(half ,_FogOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_FogNoiseOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_DepthFogOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_HeightFogOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_SphereFogId)
    
//--------------------------------- Parallax
//#if defined(_PARALLAX)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxOn) // to UNITY_DEFINE_INSTANCED_PROP(keyword ,_PARALLAX)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxIterate)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxInVSOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxHeight)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxMapChannel)
//#endif
//--------------------------------- Rain
// #if defined(_RAIN_ON)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_RainOn)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_RippleTex_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_RippleOffsetAutoStop)
    UNITY_DEFINE_INSTANCED_PROP(half,_RippleAlbedoIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RippleSpeed)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RippleIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RippleBlendNormal)

    UNITY_DEFINE_INSTANCED_PROP(half4 ,_RainColor)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainSmoothness)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainMetallic)
    UNITY_DEFINE_INSTANCED_PROP(half,_RainIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainHeight)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainSlopeAtten)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainMaskFrom)

    // UNITY_DEFINE_INSTANCED_PROP(half,_RainReflectOn)
    UNITY_DEFINE_INSTANCED_PROP(half3 ,_RainReflectDirOffset)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_RainFlowTilingOffset)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainReflectIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half ,_RainFlowIntensity)
// #endif

// #if defined(_SURFACE_BELOW_ON)
    UNITY_DEFINE_INSTANCED_PROP(half ,_SurfaceBelowOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_SurfaceDepth)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_BelowColor)
// #endif

// #if defined(_STOREY_ON)
    UNITY_DEFINE_INSTANCED_PROP(half4 ,_StoreyWindowInfo)
    UNITY_DEFINE_INSTANCED_PROP(half ,_StoreyTilingOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_StoreyLightSwitchSpeed)
    UNITY_DEFINE_INSTANCED_PROP(half,_StoreyHeight)
    UNITY_DEFINE_INSTANCED_PROP(half,_StoreyLineOn)

    // UNITY_DEFINE_INSTANCED_PROP(half4 ,_StoreyTiling_LightSwitchSpeed_Height_Line)
    
    UNITY_DEFINE_INSTANCED_PROP(half4,_StoreyLineColor)
    UNITY_DEFINE_INSTANCED_PROP(half,_StoreyLightOpaque)
// #endif    
// detail
// #if defined(_DETAIL_ON)
    UNITY_DEFINE_INSTANCED_PROP(half4,_DetailPBRMaskMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPBRMetallic)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPBRSmoothness)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPBROcclusion)

    UNITY_DEFINE_INSTANCED_PROP(half,_DetailWorldPlaneMode)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailWorldPosTriplanar)
    
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPbrMaskApplyMetallic)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPbrMaskApplySmoothness)
    UNITY_DEFINE_INSTANCED_PROP(half,_DetailPbrMaskApplyOcclusion)
// #endif

    UNITY_DEFINE_INSTANCED_PROP(half4,_IBLCube_HDR)

    // UNITY_DEFINE_INSTANCED_PROP(half,_BoxProjectionOn)

    UNITY_DEFINE_INSTANCED_PROP(half,_BigShadowOff)
    UNITY_DEFINE_INSTANCED_PROP(half,_CurvedBackwardScale)
    UNITY_DEFINE_INSTANCED_PROP(half,_CurvedSidewayScale)

    UNITY_DEFINE_INSTANCED_PROP(half,_CustomShadowDepthBias)
    UNITY_DEFINE_INSTANCED_PROP(half,_CustomShadowNormalBias)
    
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

/**
    Weather vars
*/
// #define IsRainOn() (_IsGlobalRainOn && _RainOn)
// #define IsSnowOn() (_IsGlobalSnowOn && _SnowOn)
// #define IsWindOn() (_IsGlobalWindOn && _WindOn)

//--------------------------------- Main
    #define _BaseMap_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BaseMap_ST)
    #define _Color UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Color)
    #define _AlbedoMulVertexColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_AlbedoMulVertexColor)
    #define _NormalMap_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_NormalMap_ST)

    #define _NormalScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_NormalScale)
    #define _Cutoff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Cutoff)
    #define _AlphaPremultiply UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_AlphaPremultiply) // _ALPHA_PREMULTIPLY_ON
    #define _GIApplyMainLightShadow UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_GIApplyMainLightShadow)
    #define _MainLightShadowSoftScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainLightShadowSoftScale)

    #define _Metallic UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Metallic)
    #define _Smoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Smoothness)
    #define _MRTSmoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MRTSmoothness)
    #define _Occlusion UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Occlusion)
    #define _InvertSmoothnessOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_InvertSmoothnessOn)

    #define _MetallicChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MetallicChannel)
    #define _SmoothnessChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SmoothnessChannel)
    #define _OcclusionChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OcclusionChannel)
    // #define _ClipOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ClipOn) // to keyword _ALPHATEST_ON
//--------------------------------- Emission
    #define _EmissionOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionOn) // to keyword _EMISSION
    #define _EmissionColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionColor)

    #define _EmissionHeightOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionHeightOn)
    #define _EmissionHeightColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionHeightColor)
    #define _EmissionHeight UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionHeight)
    #define _EmissionHeightColorNormalAttenOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionHeightColorNormalAttenOn)

    #define _EmissionScanLineOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineOn)
    // #define _EmissionScanLineColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineColor)
    // #define _EmissionScanLineMin UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineMin)
    // #define _EmissionScanLineMax UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineMax)
    // #define _EmissionScanLineRate UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EmissionScanLineRate)

    #define _IsReceiveShadowOff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_IsReceiveShadowOff) // to keyword _RECEIVE_SHADOWS_OFF
    #define _ScreenShadowOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ScreenShadowOn) 
    
//--------------------------------- IBL
    #define _IBLOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_IBLOn)
    #define _EnvIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvIntensity)
    #define _IBLMaskMainTexA UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_IBLMaskMainTexA)
    #define _ReflectDirOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ReflectDirOffset)
    #define _InteriorMapOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_InteriorMapOn)
//--------------------------------- Custom Light
    #define _CustomLightOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightOn) //_CUSTOM_LIGHT_ON
    #define _CustomLightDir UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightDir)
    #define _CustomLightColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightColor)
    #define _CustomLightColorUsage UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightColorUsage)
    #define _FresnelIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FresnelIntensity)
//--------------------------------- lightmap
    #define _LightmapColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_LightmapColor)
//--------------------------------- Wind
    #define _WindOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WindOn)
    #define _WindAnimParam UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WindAnimParam)
    #define _WindDir UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WindDir)
    #define _WindSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_WindSpeed)
//--------------------------------- Plannar Reflection
    #define _PlanarReflectionOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PlanarReflectionOn) // _PLANAR_REFLECTION_ON
    #define _PlanarReflectionReverseU UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PlanarReflectionReverseU)
    #define _PlanarReflectionReverseV UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PlanarReflectionReverseV)
//--------------------------------- Snow
    #define _SnowOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SnowOn)
    #define _SnowIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SnowIntensity)
    #define _SnowIntensityUseMainTexA UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SnowIntensityUseMainTexA)
    #define _ApplyEdgeOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ApplyEdgeOn)

    #define _SnowNormalMask UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SnowNormalMask)
    #define _SnowNoiseTiling UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SnowNoiseTiling)
    #define _SnowNoiseWeights UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SnowNoiseWeights)

//--------------------------------- Fog
    #define _FogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FogOn)
    #define _FogNoiseOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FogNoiseOn)
    #define _SphereFogId UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SphereFogId)
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
    #define _RippleBlendNormal UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RippleBlendNormal)
//--------------------------------- Rain reflection
    #define _RainColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainColor)
    #define _RainSmoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainSmoothness)
    #define _RainMetallic UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainMetallic)
    // #define _RainReflectOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainReflectOn)
    #define _RainReflectDirOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainReflectDirOffset)
    #define _RainFlowTilingOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainFlowTilingOffset)
    #define _RainHeight UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainHeight)
    #define _RainIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainIntensity)
    #define _RainReflectIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainReflectIntensity)
    #define _RainFlowIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RainFlowIntensity)
    
    #define _SurfaceDepth UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SurfaceDepth)
    #define _SurfaceBelowOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SurfaceBelowOn)
    #define _BelowColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BelowColor)
//--------------------------------- Storey
    #define _StoreyWindowInfo UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyWindowInfo)
    #define _StoreyTilingOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyTilingOn)
    #define _StoreyLightSwitchSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyLightSwitchSpeed)
    #define _StoreyHeight UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyHeight)
    #define _StoreyLineOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyLineOn)
    #define _StoreyLineColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StoreyLineColor)

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


    #define _BigShadowOff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BigShadowOff) 
    #define _CurvedBackwardScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CurvedBackwardScale) 
    #define _CurvedSidewayScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CurvedSidewayScale) 
    #define _CustomShadowDepthBias UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomShadowDepthBias) 
    #define _CustomShadowNormalBias UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomShadowNormalBias) 

#endif //POWER_LIT_INPUT_HLSL