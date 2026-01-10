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
#include "Lights.hlsl"

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

    o.vertex = (_MainLightPosition.w==0) ? float4(v.vertex.xy*2,UNITY_RAW_FAR_CLIP_VALUE,1) : UnityObjectToClipPos(v.vertex.xyz);
// o.vertex = UnityObjectToClipPos(v.vertex.xyz);
    // if(_MainLightPosition.w==0)
        // FullScreenTriangleVert(vid,o.vertex/**/,o.uv.xy/**/);

    return o;
}

float4 frag (v2f i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);

    float2 screenUV = i.vertex.xy/_ScaledScreenParams.xy;

    float4 gbuffer0 = tex2D(_GBuffer0,screenUV); // albedo
    float4 gbuffer1 = tex2D(_GBuffer1,screenUV); // normal
    float4 gbuffer2 = tex2D(_GBuffer2,screenUV); // pbrMask

    // float4 gbuffer3 = tex2D(_GBuffer3,screenUV);
    half3 emission = half3(gbuffer0.w,gbuffer1.w,0);

    half3 albedo = gbuffer0.xyz; // include gi

    float3 normal = float3(gbuffer1.xyz);
    normal.xyz = normal.xyz *2-1;

    // normal.z = sqrt(1.0 - saturate(dot(normal.xy,normal.xy)));
    // normal = normalize(normal);
// return float4(normal.xyz,0);
    float3 pbrMask = float3(gbuffer2.xyz);
    float shadowAtten = gbuffer2.w;

    // return shadowAtten;
    #if defined(SHADER_API_GLES3)
    float4 gbuffer4 = tex2D(_GBuffer4,screenUV); // worldPos only gles3
    float3 worldPos = gbuffer4.xyz;
    #else
    float depthTex = tex2D(_CameraDepthAttachment,screenUV).x;
    float3 worldPos = ScreenToWorldPos(screenUV,depthTex,UNITY_MATRIX_I_VP);
    #endif

    Light light = GetLight(_MainLightPosition,
    _MainLightColor.xyz,
    shadowAtten,worldPos,
    _LightAttenuation,
    _LightDirection,
    _Radius,
    _Intensity,
    _Falloff,
    _IsSpot,
    _SpotLightAngle);

    // float3 worldPos1 = ScreenToWorldPos(tex2D(_CameraDepthAttachment,screenUV+float2(1/_ScaledScreenParams.x,0)),depthTex,UNITY_MATRIX_I_VP);
    // float3 worldPos2 = ScreenToWorldPos(tex2D(_CameraDepthAttachment,screenUV+float2(0,1/_ScaledScreenParams.y)),depthTex,UNITY_MATRIX_I_VP);
    // normal = normalize(cross(ddy(worldPos),ddx(worldPos)));
    
    // pbr mask
    float metallic = pbrMask.x;
    float smoothness =pbrMask.y;
    float occlusion =pbrMask.z;

    float roughness = 0;
    float a = 0;
    float a2 = 0;
    CalcRoughness(roughness/**/,a/**/,a2/**/,smoothness);

    float3 l = light.direction;
    float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
    float3 h = normalize(l+v);
    float3 n = normalize(normal);
    float lh = saturate(dot(l,h));
    float nh = saturate(dot(n,h));
    float nl = saturate(dot(n,l));
    // return nl;

    float nv = saturate(dot(n,v));


    float3 radiance = light.color * light.distanceAttenuation  * max(0.1,light.shadowAttenuation * nl);

    float specTerm = MinimalistCookTorrance(nh,lh,a,a2);

    float3 specColor = lerp(0.04,albedo,metallic);
    float3 diffColor = albedo * (1 - metallic);
    float3 directColor = (diffColor + specColor * specTerm) * radiance;

    // if(_MainLightPosition.w == 1){
    //     return light.distanceAttenuation;
    // }
    // float3 giDiff = SampleSH(float4(normal,1));

    half4 col = (half4)0;
    col.xyz = directColor;
    // col.xyz += emission;
    return col;
}

#endif //PBR_FORWARD_PASS_HLSL