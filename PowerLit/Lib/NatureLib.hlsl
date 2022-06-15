#if !defined(NATURE_LIB_HLSL)
#define NATURE_LIB_HLSL
#include "NodeLib.hlsl"

/**
    controlled by WeahterControl.cs
*/
half4 _GlobalWindDir; /*global wind direction*/
half _GlobalSnowIntensity; 

half4 SmoothCurve( half4 x ) {
    return x * x *( 3.0 - 2.0 * x );
}
half4 TriangleWave( half4 x ) {
    return abs( frac( x + 0.5 ) * 2.0 - 1.0 );
}
half4 SmoothTriangleWave( half4 x ) {
    return SmoothCurve( TriangleWave( x ) );
}

// Detail bending
inline half4 AnimateVertex(half4 pos, half3 normal, half4 animParams,half4 windDir)
{
    // animParams stored in color
    // animParams.x = branch phase
    // animParams.y = edge flutter factor
    // animParams.z = primary factor
    // animParams.w = secondary factor

    half fDetailAmp = 0.1f;
    half fBranchAmp = 0.3f;

    // Phases (object, vertex, branch)
    half fObjPhase = dot(unity_ObjectToWorld._14_24_34, 1);
    half fBranchPhase = fObjPhase + animParams.x;

    half fVtxPhase = dot(pos.xyz, animParams.y + fBranchPhase);

    // x is used for edges; y is used for branches
    half2 vWavesIn = _Time.yy + half2(fVtxPhase, fBranchPhase );

    // 1.975, 0.793, 0.375, 0.193 are good frequencies
    half4 vWaves = (frac( vWavesIn.xxyy * half4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0);

    vWaves = SmoothTriangleWave( vWaves );
    half2 vWavesSum = vWaves.xz + vWaves.yw;

    // Edge (xz) and branch bending (y)
    half3 bend = animParams.y * fDetailAmp * normal.xyz;
    bend.y = animParams.w * fBranchAmp;
    pos.xyz += ((vWavesSum.xyx * bend) + (windDir.xyz * vWavesSum.y * animParams.w)) * windDir.w;

    // Primary bending
    // Displace position
    pos.xyz += animParams.z * windDir.xyz;

    return pos;
}



half4 WindAnimationVertex( half3 worldPos,half3 vertex,half3 normal,half4 atten_AnimParam,half4 windDir){
    half windIntensity = windDir.w;
    // worldPos,normal, attenParam * animParam, windDir
    windDir += _GlobalWindDir;

    half yAtten = saturate(vertex.y/10); // local position'y atten

    half gradientNoise = unity_gradientNoise(worldPos.xz*0.1+half2(_Time.x,0)) + 0.5;
    atten_AnimParam.w += gradientNoise * 0.1 *windIntensity;
    atten_AnimParam *= yAtten;

    windDir.xyz = clamp(windDir.xyz,-1,1);
    return AnimateVertex(half4(worldPos,1),normal,atten_AnimParam,windDir);
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
void SimpleWave(inout half3 worldPos,half3 vertex,half3 vertexColor,half bend,half3 dir,half2 noiseUV,half noiseSpeed,half noiseScale,half noiseStrength){
    half y = vertex.y * bend * _CosTime.w * 0.01+ 1;
    half y2 = y*y;
    half y4 = y2*y2;
    dir *= (y4-y2);

    noiseUV += _Time.xx * noiseSpeed;
    half noise = 0;
    Unity_GradientNoise_half(noiseUV,noiseScale,noise/**/);
    dir.xz += noise * noiseStrength;
    
    half2 offsetPos = lerp(0,dir.xz,vertexColor.xy);
    worldPos.xz += offsetPos;
}

/**
    Simple Snow from albedo
*/
half3 MixSnow(half3 albedo,half3 snowColor,half intensity,half3 worldNormal){
    half g = dot(half3(0.2,0.7,0.02),albedo);
    half rate = smoothstep(0.4,0.2,g*intensity * _GlobalSnowIntensity);

    half dirAtten = saturate(dot(worldNormal,_GlobalWindDir.xyz)); // filter by dir
    rate = max(rate , dirAtten);
    return lerp(snowColor,albedo,smoothstep(.2,.8,rate));
}

#endif //NATURE_LIB_HLSL