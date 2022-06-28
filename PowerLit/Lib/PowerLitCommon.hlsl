#if !defined(POWER_LIT_COMMON_HLSL)
#define POWER_LIT_COMMON_HLSL

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Version.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"


#define branch_if UNITY_BRANCH if

float3 ScreenToWorldPos(float2 screenUV,float depth,float4x4 invVP){
    screenUV.y = 1 - screenUV.y;

    float4 p = float4(screenUV*2-1,depth,1);
    p = mul(invVP,p);
    return p.xyz/p.w;
}


#endif // POWER_LIT_COMMON_HLSL