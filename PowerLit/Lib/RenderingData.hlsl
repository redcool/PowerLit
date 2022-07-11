#if !defined(RENDERING_DATA_HLSL)
#define RENDERING_DATA_HLSL

/**
    transformd by PowerURPLitFeatures.cs
    add PowerURPLitFeatures to (Forward Renderer Data)
**/

#define LIGHT_MODE_DISABLED 0
#define LIGHT_MODE_PIXEL 1
#define LIGHT_MODE_VERTEX 2

CBUFFER_START(RenderingData)
    bool _MainLightShadowOn; // URP Asset mainlight shadow is on?
    bool _MainLightShadowCascadeOn;
    bool _Shadows_ShadowMaskOn;
    bool _LightmapOn;
    int _MainLightMode; //{0 : disable,1 : pixel, 2 :vertex}
    int _AdditionalLightMode;
    bool _DistanceShadowMaskOn;
    half4 _LightmapParams; // (lightmapSH,lightmapSaturate,lightmapIntensity)
CBUFFER_END

#define IsAdditionalLightVertex() (_AdditionalLightMode == LIGHT_MODE_VERTEX)
#define IsAdditionalLightPixel() (_AdditionalLightMode == LIGHT_MODE_PIXEL)
#define IsShadowMaskOn() (_Shadows_ShadowMaskOn)
#define IsLightmapOn() (_LightmapOn)
#define IsMainLightShadowCascadeOn() (_MainLightShadowCascadeOn)
#define IsDistanceShadowMaskOn() (_Shadows_ShadowMaskOn && _DistanceShadowMaskOn)

#define _LightmapSH _LightmapParams.x
#define _LightmapSaturate _LightmapParams.y
#define _LightmapIntensity _LightmapParams.z

#endif //RENDERING_DATA_HLSL