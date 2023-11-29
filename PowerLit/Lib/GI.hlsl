#if !defined(GI_HLSL)
#define GI_HLSL

#include "../../PowerShaderLib/Lib/GILib.hlsl"

float4 SamplePlanarReflectionTex(float2 suv){
    return SAMPLE_TEXTURE2D(_ReflectionTexture,sampler_ReflectionTexture,suv);
}

#endif // GI_HLSL