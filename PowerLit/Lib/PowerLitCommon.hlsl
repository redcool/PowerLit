#if !defined(POWER_LIT_COMMON_HLSL)
#define POWER_LIT_COMMON_HLSL
// #define USE_URP
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"

// for d3d error
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#include "../../PowerShaderLib/Lib/PowerUtils.hlsl"

#define branch_if UNITY_BRANCH if

/***
    transfer _ALPHATEST_ON to ALPHA_TEST
    unified FastLit
*/
#undef ALPHA_TEST
#if defined(_ALPHATEST_ON)
    #define ALPHA_TEST
#endif

// #define UNITY_BRANCH
#endif // POWER_LIT_COMMON_HLSL