#if !defined(FOG_LIB_CGINC)
#define FOG_LIB_CGINC

float _HeightFogMin,_HeightFogMax;
float4 _HeightFogMinColor,_HeightFogMaxColor;
float4 _FogNearColor;
float2 _FogDistance;

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

    fog.x = saturate(smoothstep(0.25,1,depth) + lerp(0.,0.3,height));
    fog.y = saturate( height);
    return fog;
}

void BlendFogSphere(float2 fog,bool hasHeightFog,inout float3 mainColor){
    branch_if(hasHeightFog){
        float3 heightFogColor = lerp(_HeightFogMinColor,_HeightFogMaxColor,fog.y).xyz;
        float depthFactor = smoothstep(0.5,1, 1-fog.x);
        mainColor = lerp(heightFogColor,mainColor,saturate(max(depthFactor,fog.y)));
        // mainColor = fog.y;
        // return ;
    }
    float3 fogColor = lerp(_FogNearColor.rgb,unity_FogColor.rgb,fog.x);
    mainColor = lerp(mainColor,fogColor, fog.x);
    // mainColor = fog.x;
}
#endif //FOG_LIB_CGINC