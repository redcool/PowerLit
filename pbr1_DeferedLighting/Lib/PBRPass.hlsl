#if !defined(PBR_FORWARD_PASS_HLSL)
#define PBR_FORWARD_PASS_HLSL

#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/Lib/BSDF.hlsl"
#include "../../PowerShaderLib/Lib/Colors.hlsl"
#include "../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../PowerShaderLib/URPLib/Lighting.hlsl"
#include "../../PowerShaderLib/Lib/ParallaxLib.hlsl"
#include "../../PowerShaderLib/Lib/BlitLib.hlsl"
#include "../../PowerShaderLib/Lib/PowerUtils.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1:TEXCOORD1;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 uv : TEXCOORD0; // mainUV,lightmapUV
    float4 vertex : SV_POSITION;
    float4 fogCoord:TEXCOORD5;
    float4 viewDirTS:TEXCOORD6;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f vert (appdata v,uint vid:SV_VERTEXID)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);

    o.vertex = UnityObjectToClipPos(v.vertex.xyz);

    if(_MainLightPosition.w==0)
        FullScreenTriangleVert(vid,o.vertex/**/,o.uv.xy/**/);

    return o;
}

float4 frag (v2f i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);

    float2 screenUV = i.vertex.xy/_ScaledScreenParams.xy;

    float4 gbuffer0 = tex2D(_GBuffer0,screenUV);
    float4 gbuffer1 = tex2D(_GBuffer1,screenUV);
    float4 gbuffer2 = tex2D(_GBuffer2,screenUV);
    // float4 gbuffer3 = tex2D(_GBuffer3,screenUV);
    // return gbuffer0;
    half3 albedo = gbuffer0.xyz;
    half3 emission = half3(gbuffer1.zw,gbuffer0.w);
    float3 normal = float3(gbuffer1.xy,0);
    normal.z = sqrt(dot(normal.xy,normal.xy));
    float3 pbrMask = float3(gbuffer2.xyz);
    float shadowAtten = gbuffer2.w;

    // return shadowAtten;
    float depthTex = tex2D(_CameraDepthAttachment,screenUV);
    float3 worldPos = ScreenToWorldPos(screenUV,depthTex,UNITY_MATRIX_I_VP);
    return worldPos.xyzx;

    half4 col = (half4)0;
    return col;
}

#endif //PBR_FORWARD_PASS_HLSL