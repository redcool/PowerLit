#if !defined(LIGHTING_HLSL)
#define LIGHTING_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Shadows.hlsl"
#include "GI.hlsl"
 


float MinimalistCookTorrance(float nh,float lh,float rough,float rough2){
    float d = nh * nh * (rough2-1) + 1.00001f;
    float lh2 = lh * lh;
    float spec = rough2/((d*d) * max(0.1,lh2) * (rough*4+2)); // approach sqrt(rough2)
    
    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
        spec = clamp(spec,0,100);
    #endif
    return spec;
}


float3 VertexLighting(float3 worldPos,float3 normal,bool isLightOn=false){
    float3 c = (float3)0;
    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    // branch_if(isLightOn)
    {
        int count = GetAdditionalLightsCount();
        for(int i=0;i<count;i++){
            Light light = GetAdditionalLight(i,worldPos);
            float3 lightColor = light.color * light.distanceAttenuation;
            c += LightingLambert(lightColor,light.direction,normal);
        }
    }
    #endif
    return c;
}

/***
// Light 
***/

Light GetMainLight(float4 shadowCoord,float3 worldPos,float4 shadowMask,bool isReceiveShadow){
    Light light = (Light)0;
    light.direction = _MainLightPosition.xyz;
    light.color = _MainLightColor.rgb;
    light.distanceAttenuation = unity_LightData.z; // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
    light.shadowAttenuation = MainLightShadow(shadowCoord,worldPos,shadowMask,_MainLightOcclusionProbes);
    return light;
}


Light GetMainLight(SurfaceInputData data,float4 shadowMask){
    Light mainLight = GetMainLight(data.inputData.shadowCoord,data.inputData.positionWS,shadowMask,true);
    return mainLight;
}

void OffsetLight(inout Light mainLight,inout float3 specularColor){
    // #if defined(_CUSTOM_LIGHT_ON)
    branch_if(_CustomLightOn)
    {
        mainLight.direction = (_CustomLightDir.xyz);
        mainLight.color = _CustomLightColorUsage == 0 ? _CustomLightColor : mainLight.color;
        specularColor *= _CustomLightColorUsage== 1? _CustomLightColor : 1;
    }
    // #endif
}

#define GetAdditionalLight GetAdditionalLight1
Light GetAdditionalLight1(uint i, float3 positionWS, float4 shadowMask,float softScale=1)
{
#if USE_CLUSTERED_LIGHTING
    int lightIndex = i;
#else
    int lightIndex = GetPerObjectLightIndex(i);
#endif
    Light light = GetAdditionalPerObjectLight(lightIndex, positionWS);

#if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
    float4 occlusionProbeChannels = _AdditionalLightsBuffer[lightIndex].occlusionProbeChannels;
#else
    float4 occlusionProbeChannels = _AdditionalLightsOcclusionProbes[lightIndex];
#endif
    light.shadowAttenuation = AdditionalLightShadow1(lightIndex, positionWS, light.direction, shadowMask, occlusionProbeChannels);
#if defined(_LIGHT_COOKIES)
    real3 cookieColor = SampleAdditionalLightCookie(lightIndex, positionWS);
    light.color *= cookieColor;
#endif

    return light;
}

float3 CalcLight(Light light,float3 diffColor,float3 specColor,float3 n,float3 v,float a,float a2){
    // if(!light.distanceAttenuation)
    //     return 0;
        
    float3 l = light.direction;
    float3 h = normalize(l+v);
    float nl = saturate(dot(n,l));

    float nh = saturate(dot(n,h));
    float lh = saturate(dot(l,h));

    float d = nh*nh*(a2 - 1) +1;
    float specTerm = a2/(d*d * max(0.001,lh*lh) * (4*a+2));
    float radiance = nl * light.shadowAttenuation * light.distanceAttenuation;
    return (diffColor + specColor * specTerm) * light.color * radiance;
}

float3 CalcAdditionalLights(float3 worldPos,float3 diffColor,float3 specColor,float3 n,float3 v,float a,float a2,float4 shadowMask,float softScale=1 ){
    uint count = GetAdditionalLightsCount();
    float3 c = 0;
    for(uint i=0;i<count;i++){
        Light l = GetAdditionalLight(i,worldPos,shadowMask,softScale);
        c += CalcLight(l,diffColor,specColor,n,v,a,a2);
    }
    return c;
}
#endif //LIGHTING_HLSL