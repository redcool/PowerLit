#if !defined(PBR_INPUT_HLSL)
#define PBR_INPUT_HLSL
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
#define _MainTex _BaseMap
#define _MainTex_ST _BaseMap_ST
#define _PbrMask _MetallicMaskMap
/**
    sv_target0 , xyz : albedo+giColor, w: emission.z
    sv_target1 , xy:normal.xy,zw:emission.xy
    sv_target2 , xyz:pbrMask,w:mainLightShadow
    sv_target3 , xy(16) : motion vector.xy
*/

sampler2D _GBuffer0;
sampler2D _GBuffer1;
sampler2D _GBuffer2;
sampler2D _CameraDepthAttachment;


CBUFFER_START(UnityPerMaterial)
half4 _Color;
half4 _MainTex_ST;
half _Metallic,_Smoothness,_Occlusion;

half _NormalScale;

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
half _TFOn,_TFScale,_TFOffset,_TFSaturate,_TFBrightness;

half _ReceiveShadowOff;

half _FogOn;
half _FogNoiseOn;
half _DepthFogOn;
half _HeightFogOn;

half _AlphaPremultiply;
half _Cutoff;

half4 _EmissionColor;

half _ParallaxOn,_ParallaxIterate,_ParallaxHeight,_ParallaxMapChannel;

CBUFFER_END

#endif //PBR_INPUT_HLSL