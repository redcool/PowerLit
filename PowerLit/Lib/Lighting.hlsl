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

void OffsetLight(inout Light mainLight,inout BRDFData brdfData){
    #if defined(_CUSTOM_LIGHT_ON)
    // branch_if(_CustomLightOn)
    {
        mainLight.direction = (_CustomLightDir.xyz);

        switch(_CustomLightColorUsage){
            case 0 : mainLight.color = _CustomLightColor.xyz; break;
            case 1 : brdfData.specular *= _CustomLightColor.xyz; break;
        }
    }
    #endif
}

// void InitBRDFData(SurfaceInputData surfaceInputData,inout float alpha,out BRDFData brdfData){
//     SurfaceData surfaceData = surfaceInputData.surfaceData;
//     float oneMinusReflectivityMetallic = OneMinusReflectivityMetallic(surfaceData.metallic);
    
//     brdfData = (BRDFData)0;
//     // brdfData.albedo = surfaceData.albedo;
//     brdfData.reflectivity = 1 - oneMinusReflectivityMetallic;
//     brdfData.diffuse = surfaceData.albedo * oneMinusReflectivityMetallic;
//     brdfData.specular = lerp(0.04,surfaceData.albedo,surfaceData.metallic);
//     brdfData.perceptualRoughness = 1 - surfaceData.smoothness;
//     brdfData.roughness = max(HALF_MIN_SQRT,brdfData.perceptualRoughness * brdfData.perceptualRoughness);
//     brdfData.roughness2 = max(brdfData.roughness * brdfData.roughness,HALF_MIN);
//     brdfData.grazingTerm = saturate( (surfaceData.smoothness + brdfData.reflectivity)) * _FresnelIntensity; // (smoothness + metallic)
//     // brdfData.normalizationTerm = brdfData.roughness * 4 + 2; // mct factor
//     // brdfData.roughness2MinusOne = brdfData.roughness2 - 1; // mct factor

//     // #if defined(_ALPHA_PREMULTIPLY_ON)
//     if(surfaceInputData.isAlphaPremultiply)
//     {
//         brdfData.diffuse *= alpha;
//         alpha = alpha * oneMinusReflectivityMetallic + brdfData.reflectivity; //lerp(a,1,m)
//     }
//     // #endif
// }

// float3 CalcPBRLighting(BRDFData brdfData,float3 lightColor,float3 lightDir,float lightAtten,float3 normal,float3 viewDir){
//     float nl = saturate(dot(normal,lightDir));
//     float3 radiance = lightColor * (lightAtten * nl); // light's color

//     float3 brdf = brdfData.diffuse;
//     brdf += brdfData.specular * CalcDirectSpecularTerm(brdfData.roughness,brdfData.roughness2,lightDir,viewDir,normal);
//     return brdf * radiance;
// }

// float3 CalcAdditionalPBRLighting(BRDFData brdfData,InputData inputData,float4 shadowMask){
//     uint lightCount = GetAdditionalLightsCount();
//     float3 c = (float3)0;
//     for(uint i=0;i<lightCount;i++)
//     {
//         Light light = GetAdditionalLight1(i,inputData.positionWS,shadowMask);
//         // float3 attenColor = max(light.shadowAttenuation,inputData.bakedGI);

//         // OffsetLight(light/**/);

//         // branch_if(light.distanceAttenuation)
//             c+= CalcPBRLighting(brdfData,light.color,light.direction,light.distanceAttenuation * light.shadowAttenuation,inputData.normalWS,inputData.viewDirectionWS);
//     }
//     return c;
// }


// float4 CalcPBR(SurfaceInputData data,Light mainLight,float4 shadowMask){
//     SurfaceData surfaceData = data.surfaceData;
//     InputData inputData = data.inputData;

//     BRDFData brdfData;
//     InitBRDFData(data,surfaceData.alpha/*inout*/,brdfData/*out*/);
    
//     half3 lastSpecular = brdfData.specular;
//     // MixRealtimeAndBakedGI(mainLight,inputData.normalWS,inputData.bakedGI);
// // return (brdfData.diffuse + inputData.bakedGI*0.2).xyzx+shadowMask*0.1;
//     float customIBLMask = _IBLMaskMainTexA ? surfaceData.alpha : 1;
//     float3 color = CalcGI(brdfData,inputData.bakedGI,surfaceData.occlusion,inputData.normalWS,inputData.viewDirectionWS,customIBLMask,inputData.positionWS,data);

//     // color *= _GIApplyMainLightShadow ? clamp(mainLight.shadowAttenuation,0.5,1) : 1;

//     // UNITY_BRANCH if(mainLight.distanceAttenuation)
//     {
//         OffsetLight(mainLight/**/,brdfData/**/);
//         color += CalcPBRLighting(brdfData,mainLight.color,mainLight.direction,mainLight.distanceAttenuation * mainLight.shadowAttenuation,inputData.normalWS,inputData.viewDirectionWS);
//     }
//     color += surfaceData.emission;

//     #if defined(_ADDITIONAL_LIGHTS_VERTEX)
//     // branch_if(IsAdditionalLightVertex())
//     {
//         color += inputData.vertexLighting * brdfData.diffuse;
//     }
//     #endif

//     #if defined(_ADDITIONAL_LIGHTS)
//     // branch_if(IsAdditionalLightPixel())
//     {
//         brdfData.specular = lastSpecular;
//         color += CalcAdditionalPBRLighting(brdfData,inputData,shadowMask);
//         // return CalcAdditionalPBRLighting(brdfData,inputData,shadowMask).xyzx;
//     }
//     #endif

//     return float4(color,surfaceData.alpha);
// }


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