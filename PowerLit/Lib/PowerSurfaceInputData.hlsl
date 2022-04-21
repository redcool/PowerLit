#if !defined(POWER_SUFRACE_INPUT_DATA_HLSL)
#define POWER_SUFRACE_INPUT_DATA_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "RenderingData.hlsl"

struct SurfaceInputData{
    SurfaceData surfaceData;
    InputData inputData;
    bool isAlphaPremultiply;
    bool isReceiveShadow; // material prop
    half lightmapSH;
    half lmSaturate;
    half2 screenUV;
    // bool hasShadowCascade;
};



#endif //POWER_SUFRACE_INPUT_DATA_HLSL