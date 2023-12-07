#if !defined(GI_HLSL)
#define GI_HLSL

#include "../../PowerShaderLib/Lib/GILib.hlsl"

float4 SamplePlanarReflectionTex(float2 suv,half lod){
    return SAMPLE_TEXTURE2D_LOD(_ReflectionTexture,sampler_ReflectionTexture,suv,lod);
}

#endif // GI_HLSL