/**
do not use this file
*/

#if !defined(PBR_INPUT_MIN_HLSL)
#define PBR_INPUT_MIN_HLSL
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"

//for compatible PowerLit
#define _PbrMask _MetallicMaskMap
#define _MainTex _BaseMap
#define _MainTex_ST _BaseMap_ST

sampler2D _MainTex;
sampler2D _NormalMap;
sampler2D _PbrMask;
sampler2D _EmissionMap;
sampler2D _ReflectionTexture;

TEXTURE2D(_RippleTex);SAMPLER(sampler_RippleTex);
TEXTURECUBE(_IBLCube); SAMPLER(sampler_IBLCube);
TEXTURE2D(_DetailPBRMaskMap);SAMPLER(sampler_DetailPBRMaskMap);

CBUFFER_START(UnityPerMaterial)
half4 _Color;
half4 _MainTex_ST;
// half4 _Metallic_Smoothness_Occlusion_NormalScale;
half _Metallic,_Smoothness,_Occlusion,_NormalScale;
half _AlbedoMulVertexColor;

half _SpecularOn;
// half _AnisoRough;
// half _AnisoShift;

// half _PbrMode;
// half _CalcTangent;

// custom shadow 
half _MainLightShadowSoftScale;
half _CustomShadowDepthBias,_CustomShadowNormalBias;

// half _CalcAdditionalLights,_ReceiveAdditionalLightShadow,_AdditionalIghtSoftShadow;

//thin film
// half _TFOn,_TFScale,_TFOffset,_TFSaturate,_TFBrightness;
half _ReceiveShadowOff;
//----------------------------------------
half _FogOn;
half _FogNoiseOn;
half _DepthFogOn;
half _HeightFogOn;
//----------------------------------------
half _AlphaPremultiply;
half _Cutoff;

half4 _EmissionColor;

CBUFFER_END
#endif //PBR_INPUT_MIN_HLSL