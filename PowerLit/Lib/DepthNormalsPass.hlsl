#if !defined(DEPTH_NORMALS_PASS_HLSL)
#define DEPTH_NORMALS_PASS_HLSL
#include "PowerLitInput.hlsl"

struct appdata{
    float4 pos:POSITION;
    float2 uv:TEXCOORD;
    float3 normal:NOMRAL;
    float4 tangent:TANGENT;
    float4 color:COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f{
    float4 pos:SV_POSITION;
    float2 uv:TEXCOORD;
    float4 tSpace0:TEXCOORD1;
    float4 tSpace1:TEXCOORD2;
    float4 tSpace2:TEXCOORD3;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO    
};

v2f vert(appdata i){
    v2f o= (v2f)0;
    float sign = i.tangent.w * GetOddNegativeScale();
    float3 worldPos = TransformObjectToWorld(i.pos.xyz);
    float3 n = TransformObjectToWorldNormal(i.normal);
    float3 t = TransformObjectToWorldDir(i.tangent.xyz);
    float3 b = normalize(cross(n,t)) * sign;

    float4 attenParam = i.color.x; // vertex color atten
    branch_if(IsWindOn()){
        worldPos = WindAnimationVertex(worldPos,i.pos.xyz,n,attenParam * _WindAnimParam, _WindDir,_WindSpeed).xyz;
    }

    o.tSpace0 = float4(t.x,b.x,n.x,worldPos.x);
    o.tSpace1 = float4(t.y,b.y,n.y,worldPos.y);
    o.tSpace2 = float4(t.z,b.z,n.z,worldPos.z);
    o.uv = TRANSFORM_TEX(i.uv,_BaseMap);
    o.pos = TransformWorldToHClip(worldPos);
    return o;
}

float4 frag(v2f v):SV_TARGET{
    #if defined(_ALPHATEST_ON)
        float4 albedo = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,v.uv);
        clip(albedo.w - _Cutoff);
    #endif

    float3 tn = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,v.uv),_NormalScale);
    float3 wn = float3(
        dot(tn,v.tSpace0.xyz),
        dot(tn,v.tSpace1.xyz),
        dot(tn,v.tSpace2.xyz)
    );
    return float4(wn,0);
}

#endif //DEPTH_NORMALS_PASS_HLSL