#if !defined(PBR_INPUT_HLSL)
#define PBR_INPUT_HLSL
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"

//for compatible PowerLit
#define _PbrMask _MetallicMaskMap

sampler2D _MainTex;
sampler2D _NormalMap;
sampler2D _PbrMask;
sampler2D _EmissionMap;

CBUFFER_START(UnityPerMaterial)
half4 _Color;
half4 _MainTex_ST;
half4 _Metallic_Smoothness_Occlusion_NormalScale;

half _SpecularOn;
half _AnisoRough;
half _AnisoShift;

int _PbrMode;
half _CalcTangent;

// custom shadow 
half _MainLightShadowSoftScale;
half _CustomShadowDepthBias,_CustomShadowNormalBias;

// half _CalcAdditionalLights,_ReceiveAdditionalLightShadow,_AdditionalIghtSoftShadow;

//thin film
// half _TFOn,_TFScale,_TFOffset,_TFSaturate,_TFBrightness;
half _ReceiveShadowOff;

half _FogOn;
half _FogNoiseOn;
half _DepthFogOn;
half _HeightFogOn;

half _AlphaPremultiply;
half _Cutoff;

half4 _EmissionColor;

CBUFFER_END

#define _Metallic _Metallic_Smoothness_Occlusion_NormalScale.x
#define _Smoothness _Metallic_Smoothness_Occlusion_NormalScale.y 
#define _Occlusion _Metallic_Smoothness_Occlusion_NormalScale.z
#define _NormalScale _Metallic_Smoothness_Occlusion_NormalScale.w
#endif //PBR_INPUT_HLSL