#if !defined(LIGHTING_HLSL)
#define LIGHTING_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Shadows.hlsl"
#include "GI.hlsl"

half3 VertexLighting(half3 worldPos,half3 normal,bool isLightOn){
    half3 c = (half3)0;
    if(isLightOn){
        int count = GetAdditionalLightsCount();
        for(int i=0;i<count;i++){
            Light light = GetAdditionalLight(i,worldPos);
            half3 lightColor = light.color * light.distanceAttenuation;
            c += LightingLambert(lightColor,light.direction,normal);
        }
    }
    return c;
}

/***
// Light 
***/

Light GetMainLight(half4 shadowCoord,half3 worldPos,half4 shadowMask,bool isReceiveShadow){
    Light light = (Light)0;
    light.direction = _MainLightPosition.xyz;
    light.color = _MainLightColor.rgb;
    light.distanceAttenuation = unity_LightData.z; // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
    light.shadowAttenuation = MainLightShadow(shadowCoord,worldPos,shadowMask,_MainLightOcclusionProbes,isReceiveShadow);
    return light;
}

void OffsetMainLight(inout Light mainLight){
    if(_CustomLightOn){
        mainLight.color = _CustomLightColor.xyz;
        mainLight.direction = SafeNormalize(_CustomLightDir.xyz);
    }
}

// half3 SafeNormalize(half3 v){
//     half len = max(0.0000001,dot(v,v));
//     return v/rsqrt(len);
// }

void InitBRDFData(SurfaceInputData surfaceInputData,inout half alpha,out BRDFData brdfData){
    SurfaceData surfaceData = surfaceInputData.surfaceData;
    half oneMinusReflectivityMetallic = OneMinusReflectivityMetallic(surfaceData.metallic);
    
    brdfData = (BRDFData)0;
    // brdfData.albedo = surfaceData.albedo;
    brdfData.reflectivity = 1 - oneMinusReflectivityMetallic;
    brdfData.diffuse = surfaceData.albedo * oneMinusReflectivityMetallic;
    brdfData.specular = lerp(kDieletricSpec.rgb,surfaceData.albedo,surfaceData.metallic);
    brdfData.perceptualRoughness = 1 - surfaceData.smoothness;
    brdfData.roughness = max(HALF_MIN_SQRT,brdfData.perceptualRoughness * brdfData.perceptualRoughness);
    brdfData.roughness2 = max(brdfData.roughness * brdfData.roughness,HALF_MIN);
    brdfData.grazingTerm = saturate( (surfaceData.smoothness + brdfData.reflectivity)) * _FresnelIntensity; // (smoothness + metallic)
    brdfData.normalizationTerm = brdfData.roughness * 4 + 2; // mct factor
    brdfData.roughness2MinusOne = brdfData.roughness2 - 1; // mct factor

    if(surfaceInputData.isAlphaPremultiply){
        brdfData.diffuse *= alpha;
        alpha = alpha * oneMinusReflectivityMetallic + brdfData.reflectivity; //lerp(a,1,m)
    }
}

/***
    Minimalist cook torrance
    r2/(d*d * lh*lh *(4r+2))
***/
half3 CalcDirectSpecularTerm(half r/*roughness*/,half3 lightDir,half3 viewDir,half3 normal){
    half3 h = SafeNormalize(lightDir + viewDir);
    half nh = saturate(dot(normal,h));
    half lh = saturate(dot(lightDir,h));

    half r2 = r * r;
    half d = nh * nh * (r2-1)+1;
    half specTerm = r2/( d * d * max(0.1, lh * lh) * ( 4 * r + 2 ));

    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
        specTerm = clamp(specTerm,0,100);
    #endif
    return specTerm;
}



half3 CalcPBRLighting(BRDFData brdfData,half3 lightColor,half3 lightDir,half lightAtten,
    half3 normal,half3 viewDir){
    half nl = saturate(dot(normal,lightDir));
    half3 radiance = lightColor * lightAtten * nl; // light's color

    half3 brdf = brdfData.diffuse;
    brdf += brdfData.specular * CalcDirectSpecularTerm(brdfData.roughness,lightDir,viewDir,normal);
    return brdf * radiance;
}

half3 CalcAdditionalPBRLighting(BRDFData brdfData,InputData inputData,half4 shadowMask){
    uint lightCount = GetAdditionalLightsCount();
    half3 c = (half3)0;
    for(uint i=0;i<lightCount;i++){
        Light light = GetAdditionalLight(i,inputData.positionWS,shadowMask);
        c+= CalcPBRLighting(brdfData,light.color,light.direction,light.distanceAttenuation * light.shadowAttenuation,inputData.normalWS,inputData.viewDirectionWS);
    }
    return c;
}

half4 CalcPBR(SurfaceInputData data){
    SurfaceData surfaceData = data.surfaceData;
    InputData inputData = data.inputData;

    BRDFData brdfData;
    InitBRDFData(data,surfaceData.alpha/*inout*/,brdfData/*out*/);

    half4 shadowMask = CalcShadowMask(inputData);
    Light mainLight = GetMainLight(inputData.shadowCoord,inputData.positionWS,shadowMask,data.isReceiveShadow);
    OffsetMainLight(mainLight);
    
    MixRealtimeAndBakedGI(mainLight,inputData.normalWS,inputData.bakedGI);
    
    half customIBLMask = _IBLMaskMainTexA ? surfaceData.alpha : 1;
    half3 color = CalcGI(brdfData,inputData.bakedGI,surfaceData.occlusion,inputData.normalWS,inputData.viewDirectionWS,customIBLMask,inputData.positionWS);
    color += CalcPBRLighting(brdfData,mainLight.color,mainLight.direction,mainLight.distanceAttenuation * mainLight.shadowAttenuation,inputData.normalWS,inputData.viewDirectionWS);
    color += surfaceData.emission;

    if(IsAdditionalLightVertex()){
        color += inputData.vertexLighting * brdfData.diffuse;
    }

    if(IsAdditionalLightPixel()){
        color += CalcAdditionalPBRLighting(brdfData,inputData,shadowMask);
    }

    return half4(color,surfaceData.alpha);
}

#endif //LIGHTING_HLSL