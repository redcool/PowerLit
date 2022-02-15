#if !defined(NATURE_LIB_HLSL)
#define NATURE_LIB_HLSL
#include "NodeLib.cginc"

float4 SmoothCurve( float4 x ) {
    return x * x *( 3.0 - 2.0 * x );
}
float4 TriangleWave( float4 x ) {
    return abs( frac( x + 0.5 ) * 2.0 - 1.0 );
}
float4 SmoothTriangleWave( float4 x ) {
    return SmoothCurve( TriangleWave( x ) );
}

// Detail bending
inline float4 AnimateVertex(float4 pos, float3 normal, float4 animParams,float4 windDir)
{
    // animParams stored in color
    // animParams.x = branch phase
    // animParams.y = edge flutter factor
    // animParams.z = primary factor
    // animParams.w = secondary factor

    float fDetailAmp = 0.1f;
    float fBranchAmp = 0.3f;

    // Phases (object, vertex, branch)
    float fObjPhase = dot(unity_ObjectToWorld._14_24_34, 1);
    float fBranchPhase = fObjPhase + animParams.x;

    float fVtxPhase = dot(pos.xyz, animParams.y + fBranchPhase);

    // x is used for edges; y is used for branches
    float2 vWavesIn = _Time.yy + float2(fVtxPhase, fBranchPhase );

    // 1.975, 0.793, 0.375, 0.193 are good frequencies
    float4 vWaves = (frac( vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0);

    vWaves = SmoothTriangleWave( vWaves );
    float2 vWavesSum = vWaves.xz + vWaves.yw;

    // Edge (xz) and branch bending (y)
    float3 bend = animParams.y * fDetailAmp * normal.xyz;
    bend.y = animParams.w * fBranchAmp;
    pos.xyz += ((vWavesSum.xyx * bend) + (windDir.xyz * vWavesSum.y * animParams.w)) * windDir.w;

    // Primary bending
    // Displace position
    pos.xyz += animParams.z * windDir.xyz;

    return pos;
}

float4 WindAnimationVertex( float3 worldPos,float3 vertex,float3 normal,float4 atten_AnimParam,float4 windDir){
    // worldPos,normal, attenParam * animParam, windDir
    atten_AnimParam *= saturate(vertex.y/10); // local position'y atten
    windDir.xyz = clamp(windDir.xyz,-1,1);
    return AnimateVertex(float4(worldPos,1),normal,atten_AnimParam,windDir);
}

/**
    worldPos : 世界坐标
    vertex : 局部坐标
    bend : 弯曲强度
    dir : 风力方向
    noiseUV : 用于计算连续噪波的输入
    noiseSpeed  : 噪波的运动速度
    noiseScale : 噪波的缩放
    noiseStrength : 噪波的强度
*/
void SimpleWave(inout float3 worldPos,float3 vertex,float3 vertexColor,float bend,float3 dir,float2 noiseUV,float noiseSpeed,float noiseScale,float noiseStrength){
    float y = vertex.y * bend * _CosTime.w * 0.01+ 1;
    float y2 = y*y;
    float y4 = y2*y2;
    dir *= (y4-y2);

    noiseUV += _Time.xx * noiseSpeed;
    float noise = 0;
    Unity_GradientNoise_float(noiseUV,noiseScale,noise/**/);
    dir.xz += noise * noiseStrength;
    
    float2 offsetPos = lerp(0,dir.xz,vertexColor.xy);
    worldPos.xz += offsetPos;
}

/**
    Simple Snow from albedo
*/
half3 MixSnow(half3 albedo,half3 snowColor,half intensity){
    half g = dot(half3(0.2,0.7,0.02),albedo);
    half rate = smoothstep(0.4,0.2,g*intensity);
    return lerp(snowColor,albedo,rate);
}

#endif //NATURE_LIB_HLSL