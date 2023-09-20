#if !defined(POWER_SUFRACE_INPUT_DATA_HLSL)
#define POWER_SUFRACE_INPUT_DATA_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "RenderingData.hlsl"

struct SurfaceInputData{
    SurfaceData surfaceData;
    InputData inputData;
    bool isAlphaPremultiply;
    // bool isReceiveShadow; // material prop
    float2 screenUV;
    float2 uv;
    float3 viewDirTS;
    float nv;
    float envIntensity;

    // rain's info
    float3 rainReflectDirOffset;
    float rainAtten;
    float rainNoise;
};



#endif //POWER_SUFRACE_INPUT_DATA_HLSL