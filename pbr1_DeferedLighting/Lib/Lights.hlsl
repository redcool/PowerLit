#if !defined(LIGHTS_HLSL)
#define LIGHTS_HLSL
// light 
float4 _LightAttenuation;
float4 _LightDirection;
float2 _SpotLightAngle; //{outer:dot range[1,0],innerSpotAngle:dot range[1,0]}

// _LightRadiusIntensityFalloff()
float4 _LightRadiusIntensityFalloff;
#define _Radius _LightRadiusIntensityFalloff.x
#define _Intensity _LightRadiusIntensityFalloff.y
#define _Falloff _LightRadiusIntensityFalloff.z
#define _IsSpot _LightRadiusIntensityFalloff.w

/**
    Distance atten

    https://lisyarus.github.io/blog/posts/point-light-attenuation.html

float DistanceAtten(float distance,float radius,float maxIntensity,float fallOff){
    float s = distance/radius;
    float isInner = s<1;

    float s2 = Sqr(s);
    float atten = maxIntensity * Sqr(1 - s2)/(1+fallOff*s2);
    return atten * isInner;
}


*/

// float Sqr(float x){
//      return x*x;
// }
// float DistanceAtten(float distance2,float radius2,float maxIntensity,float fallOff=1){
//     float s2 = distance2/radius2;
//     float isInner = s2<1;

//     float atten = maxIntensity * Sqr(1 - s2)/(1+fallOff*s2);
//     return atten * isInner;
// }

// float AngleAtten(float3 spotDir,float3 lightDir,float outerAngle ,float innerAngle){
//     float atten = (dot(spotDir,lightDir));
//     atten *= smoothstep(outerAngle,innerAngle,atten);
//     return atten;
// }

// #define UNITY_ATTEN

/**
    use PowerShadowLib's GetLight
*/
Light GetLight(float4 lightPos,float3 color,float shadowAtten,float3 worldPos,float4 distanceAndSpotAttenuation,float3 spotLightDir){
    float3 lightDir = lightPos.xyz - worldPos * lightPos.w;
    float distSqr = max(dot(lightDir,lightDir),HALF_MIN);

    lightDir = lightDir * rsqrt(distSqr);
    float atten = 1;
    #if defined(UNITY_ATTEN)
        atten *= DistanceAttenuation(distSqr,distanceAndSpotAttenuation.xy);
        atten *= AngleAttenuation(spotLightDir,lightDir,distanceAndSpotAttenuation.zw);
    #else
        atten *= DistanceAtten(distSqr,_Radius*_Radius,_Intensity,_Falloff);
        atten *= _IsSpot ? AngleAtten(spotLightDir,lightDir,_SpotLightAngle.x,_SpotLightAngle.y) : 1;
        // atten *= AngleAtten(spotLightDir,lightDir,_SpotLightAngle.x,_SpotLightAngle.y) * _IsSpot + 1-_IsSpot;
    #endif

    Light l = (Light)0;
    l.direction = lightDir;
    l.distanceAttenuation = saturate(atten) + (1-lightPos.w);
    l.color = color;
    l.shadowAttenuation = shadowAtten;
    return l;
}

#endif //LIGHTS_HLSL