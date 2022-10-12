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
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#define branch_if UNITY_BRANCH if

half3 ScreenToWorldPos(half2 screenUV,half depth,half4x4 invVP){
    screenUV.y = 1 - screenUV.y;

    half4 p = half4(screenUV*2-1,depth,1);
    p = mul(invVP,p);
    return p.xyz/p.w;
}


#endif // POWER_LIT_COMMON_HLSL