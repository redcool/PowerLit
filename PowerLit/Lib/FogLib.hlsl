#if !defined(FOG_LIB_HLSL)
#define FOG_LIB_HLSL

#include "NodeLib.hlsl"

float _HeightFogMin,_HeightFogMax;
float4 _HeightFogMinColor,_HeightFogMaxColor;
float4 _FogNearColor;
float2 _FogDistance;
half4 _FogDirTiling;
half4 _FogNoiseParams; // composite args

#define _FogNoiseStartRate _FogNoiseParams.x
#define _FogNoiseIntensity _FogNoiseParams.y
//----------------------------Sphere Fog
float CalcDepthFactor(float dist){
    // float fogFactor =  max(((1.0-(dist)/_ProjectionParams.y)*_ProjectionParams.z),0);
    float fogFactor = dist * unity_FogParams.z + unity_FogParams.w;
    return fogFactor;
}

float3 GetFogCenter(){
    return _WorldSpaceCameraPos;
}

float2 CalcFogFactor(float3 worldPos){    
    float2 fog = 0;

    float height = saturate((worldPos.y - _HeightFogMin) / (_HeightFogMax - _HeightFogMin));

    float dist = distance(worldPos,GetFogCenter());
    float depth = saturate((dist - _FogDistance.x)/(_FogDistance.y-_FogDistance.x));

    fog.x = smoothstep(0.25,1,depth);
    fog.y = saturate( height);
    return fog;
}

void BlendFogSphere(float3 worldPos,float2 fog,bool hasHeightFog,bool fogNoiseOn,inout float3 mainColor){
    float depthFactor = fog.x;
    branch_if(fogNoiseOn){
        float gradientNoise = unity_gradientNoise( (worldPos.xz+worldPos.yz) * _FogDirTiling.w+ _FogDirTiling.xz * _Time.y );
        depthFactor = fog.x + gradientNoise * _FogNoiseIntensity * (fog.x > _FogNoiseStartRate);
    }

    branch_if(hasHeightFog){
        float3 heightFogColor = lerp(_HeightFogMinColor,_HeightFogMaxColor,fog.y).xyz;
        float heightFactor = smoothstep(0,0.1,fog.x)* (1-fog.y);

        mainColor = lerp(mainColor,heightFogColor,heightFactor);
        // mainColor = heightFactor;
        // return ;
    }
    float3 fogColor = lerp(_FogNearColor.rgb,unity_FogColor.rgb,fog.x);
    mainColor = lerp(mainColor,fogColor, depthFactor);
    // mainColor = depthFactor;
}
#endif //FOG_LIB_HLSL