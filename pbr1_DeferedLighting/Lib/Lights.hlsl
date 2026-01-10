#if !defined(LIGHTS_HLSL)
#define LIGHTS_HLSL
// light 
float4 _LightAttenuation;
float4 _LightDirection;
float2 _SpotLightAngle; //{outer:dot range[1,0],innerSpotAngle:dot range[1,0]}

float4 _LightRadiusIntensityFalloff;
#define _Radius _LightRadiusIntensityFalloff.x
#define _Intensity _LightRadiusIntensityFalloff.y
#define _Falloff _LightRadiusIntensityFalloff.z
#define _IsSpot _LightRadiusIntensityFalloff.w

#endif //LIGHTS_HLSL