#if !defined(BAKED_PBR_LIT_INPUT_HLSL)
#define BAKED_PBR_LIT_INPUT_HLSL

#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../PowerShaderLib/Lib/InstancingLib.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../PowerShaderLib/Lib/GILib.hlsl"
#include "../../PowerShaderLib/Lib/UVMapping.hlsl"
#include "../../PowerShaderLib/URPLib/URP_Lighting.hlsl"
#include "../../PowerShaderLib/URPLib/URP_MotionVectors.hlsl"
#include "../../PowerShaderLib/Lib/BigShadows.hlsl"
struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1:TEXCOORD1;
    float2 uv2:TEXCOORD2;
    float2 uv3:TEXCOORD3;
    DECLARE_MOTION_VS_INPUT(prevPos);// texcoord4
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    float4 color:COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 uv : TEXCOORD0;
    
    TANGENT_SPACE_DECLARE(1,2,3);
    float2 fogCoord:TEXCOORD4;
    // motion vectors
    DECLARE_MOTION_VS_OUTPUT(5,6);
    float4 bigShadowCoord:TEXCOORD7;
    float4 color:COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

TEXTURE2D_ARRAY(_MainTexArray);SAMPLER(sampler_MainTexArray);
TEXTURECUBE(_IBLCube); SAMPLER(sampler_IBLCube);
sampler2D _MainTex;
sampler2D _EmissionMap;
sampler2D _PbrMask;
sampler2D _NormalMap;

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
float4 _Color;
float _FogOn,_FogNoiseOn,_DepthFogOn,_HeightFogOn;
float _Cutoff;
float _NormalUnifiedOn;
float _UseUV,_UseUVReverseY;
float _MainTexArrayId;
float _MainTexUDIMOn,_MainTexUDIMCountARow;
float _PreMulVertexColor;

float _EmissionOn;
float4 _EmissionColor;
float _Metallic,_Smoothness,_Occlusion;
float3 _EnvIntensity;
float _FresnelIntensity;
float _NormalScale;
float _UV1TransformToLightmapUV;
float _PremulAlpha,_RGBMScale;

float _MainLightShadowSoftScale;
float _CustomShadowNormalBias,_CustomShadowDepthBias;
float4 _GIDiffuseColor;
float _BigShadowOff;
float _MainLightOn;
CBUFFER_END

float4 _IBLCube_HDR;;

#if defined(UNITY_DOTS_INSTANCING_ENABLED)
DOTS_CBUFFER_START(MaterialPropertyMetadata)
	// DEF_VAR(float4, _MainTex_ST)
	DEF_VAR(float4, _Color)
	DEF_VAR(float, _FogOn)
	DEF_VAR(float, _FogNoiseOn)
	DEF_VAR(float, _DepthFogOn)
	DEF_VAR(float, _HeightFogOn)
	DEF_VAR(float, _Cutoff)
	DEF_VAR(float, _NormalUnifiedOn)
	DEF_VAR(float, _UseUV)
	DEF_VAR(float, _UseUVReverseY)
	DEF_VAR(float, _MainTexArrayId)
	DEF_VAR(float, _PreMulVertexColor)
	DEF_VAR(float, _EmissionOn)
	DEF_VAR(float4, _EmissionColor)
	DEF_VAR(float, _Metallic)
	DEF_VAR(float, _Smoothness)
	DEF_VAR(float, _Occlusion)
	DEF_VAR(float3, _EnvIntensity)
	DEF_VAR(float, _FresnelIntensity)
	// DEF_VAR(float4, _IBLCube_HDR)
	DEF_VAR(float, _NormalScale)
	DEF_VAR(float, _UV1TransformToLightmapUV)
	DEF_VAR(float, _PremulAlpha)
	DEF_VAR(float, _RGBMScale)
	DEF_VAR(float, _MainLightShadowSoftScale)
	DEF_VAR(float, _CustomShadowNormalBias)
	DEF_VAR(float, _CustomShadowDepthBias)
	DEF_VAR(float4, _GIDiffuseColor)
	DEF_VAR(float, _BigShadowOff)
	DEF_VAR(float, _MainLightOn)
DOTS_CBUFFER_END

	// #define _MainTex_ST GET_VAR(float4, _MainTex_ST)
	#define _Color GET_VAR(float4, _Color)
	#define _FogOn GET_VAR(float, _FogOn)
	#define _FogNoiseOn GET_VAR(float, _FogNoiseOn)
	#define _DepthFogOn GET_VAR(float, _DepthFogOn)
	#define _HeightFogOn GET_VAR(float, _HeightFogOn)
	#define _Cutoff GET_VAR(float, _Cutoff)
	#define _NormalUnifiedOn GET_VAR(float, _NormalUnifiedOn)
	#define _UseUV GET_VAR(float, _UseUV)
	#define _UseUVReverseY GET_VAR(float, _UseUVReverseY)
	#define _MainTexArrayId GET_VAR(float, _MainTexArrayId)
	#define _PreMulVertexColor GET_VAR(float, _PreMulVertexColor)
	#define _EmissionOn GET_VAR(float, _EmissionOn)
	#define _EmissionColor GET_VAR(float4, _EmissionColor)
	#define _Metallic GET_VAR(float, _Metallic)
	#define _Smoothness GET_VAR(float, _Smoothness)
	#define _Occlusion GET_VAR(float, _Occlusion)
	#define _EnvIntensity GET_VAR(float3, _EnvIntensity)
	#define _FresnelIntensity GET_VAR(float, _FresnelIntensity)
	// #define _IBLCube_HDR GET_VAR(float4, _IBLCube_HDR)
	#define _NormalScale GET_VAR(float, _NormalScale)
	#define _UV1TransformToLightmapUV GET_VAR(float, _UV1TransformToLightmapUV)
	#define _PremulAlpha GET_VAR(float, _PremulAlpha)
	#define _RGBMScale GET_VAR(float, _RGBMScale)
	#define _MainLightShadowSoftScale GET_VAR(float, _MainLightShadowSoftScale)
	#define _CustomShadowNormalBias GET_VAR(float, _CustomShadowNormalBias)
	#define _CustomShadowDepthBias GET_VAR(float, _CustomShadowDepthBias)
	#define _GIDiffuseColor GET_VAR(float4, _GIDiffuseColor)
	#define _BigShadowOff GET_VAR(float, _BigShadowOff)
	#define _MainLightOn GET_VAR(float, _MainLightOn)
#endif
#endif //BAKED_PBR_LIT_INPUT_HLSL