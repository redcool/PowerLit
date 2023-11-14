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

void InitBRDFData(SurfaceInputData surfaceInputData,inout float alpha,out BRDFData brdfData){
    SurfaceData surfaceData = surfaceInputData.surfaceData;
    float oneMinusReflectivityMetallic = OneMinusReflectivityMetallic(surfaceData.metallic);
    
    brdfData = (BRDFData)0;
    // brdfData.albedo = surfaceData.albedo;
    brdfData.reflectivity = 1 - oneMinusReflectivityMetallic;
    brdfData.diffuse = surfaceData.albedo * oneMinusReflectivityMetallic;
    brdfData.specular = lerp(0.04,surfaceData.albedo,surfaceData.metallic);
    brdfData.perceptualRoughness = 1 - surfaceData.smoothness;
    brdfData.roughness = max(HALF_MIN_SQRT,brdfData.perceptualRoughness * brdfData.perceptualRoughness);
    brdfData.roughness2 = max(brdfData.roughness * brdfData.roughness,HALF_MIN);
    brdfData.grazingTerm = saturate( (surfaceData.smoothness + brdfData.reflectivity)) * _FresnelIntensity; // (smoothness + metallic)
    // brdfData.normalizationTerm = brdfData.roughness * 4 + 2; // mct factor
    // brdfData.roughness2MinusOne = brdfData.roughness2 - 1; // mct factor

    // #if defined(_ALPHA_PREMULTIPLY_ON)
    if(surfaceInputData.isAlphaPremultiply)
    {
        brdfData.diffuse *= alpha;
        alpha = alpha * oneMinusReflectivityMetallic + brdfData.reflectivity; //lerp(a,1,m)
    }
    // #endif
}

/***
    Minimalist cook torrance
    r2/(d*d * lh*lh *(4r+2))
***/
float3 CalcDirectSpecularTerm(float r/*roughness*/,float r2,float3 lightDir,float3 viewDir,float3 normal){
    float3 h = SafeNormalize(lightDir + viewDir);
    float nh = saturate(dot(normal,h));
    float lh = saturate(dot(lightDir,h));

    float d = nh * nh * (r2-1)+1;
    float specTerm = r2/( d * d * max(0.001, lh * lh) * ( 4 * r + 2 ));

    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
        specTerm = clamp(specTerm,0,100);
    #endif
    return specTerm;
}

float3 CalcPBRLighting(BRDFData brdfData,float3 lightColor,float3 lightDir,float lightAtten,float3 normal,float3 viewDir){
    float nl = saturate(dot(normal,lightDir));
    float3 radiance = lightColor * (lightAtten * nl); // light's color

    float3 brdf = brdfData.diffuse;
    brdf += brdfData.specular * CalcDirectSpecularTerm(brdfData.roughness,brdfData.roughness2,lightDir,viewDir,normal);
    return brdf * radiance;
}

float3 CalcAdditionalPBRLighting(BRDFData brdfData,InputData inputData,float4 shadowMask){
    uint lightCount = GetAdditionalLightsCount();
    float3 c = (float3)0;
    for(uint i=0;i<lightCount;i++)
    {
        Light light = GetAdditionalLight1(i,inputData.positionWS,shadowMask);
        // float3 attenColor = max(light.shadowAttenuation,inputData.bakedGI);

        // OffsetLight(light/**/);

        // branch_if(light.distanceAttenuation)
            c+= CalcPBRLighting(brdfData,light.color,light.direction,light.distanceAttenuation * light.shadowAttenuation,inputData.normalWS,inputData.viewDirectionWS);
    }
    return c;
}


float4 CalcPBR(SurfaceInputData data,Light mainLight,float4 shadowMask){
    SurfaceData surfaceData = data.surfaceData;
    InputData inputData = data.inputData;

    BRDFData brdfData;
    InitBRDFData(data,surfaceData.alpha/*inout*/,brdfData/*out*/);
    
    half3 lastSpecular = brdfData.specular;
    // MixRealtimeAndBakedGI(mainLight,inputData.normalWS,inputData.bakedGI);
// return (brdfData.diffuse + inputData.bakedGI*0.2).xyzx+shadowMask*0.1;
    float customIBLMask = _IBLMaskMainTexA ? surfaceData.alpha : 1;
    float3 color = CalcGI(brdfData,inputData.bakedGI,surfaceData.occlusion,inputData.normalWS,inputData.viewDirectionWS,customIBLMask,inputData.positionWS,data);

    // color *= _GIApplyMainLightShadow ? clamp(mainLight.shadowAttenuation,0.5,1) : 1;

    // UNITY_BRANCH if(mainLight.distanceAttenuation)
    {
        OffsetLight(mainLight/**/,brdfData/**/);
        color += CalcPBRLighting(brdfData,mainLight.color,mainLight.direction,mainLight.distanceAttenuation * mainLight.shadowAttenuation,inputData.normalWS,inputData.viewDirectionWS);
    }
    color += surfaceData.emission;

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    // branch_if(IsAdditionalLightVertex())
    {
        color += inputData.vertexLighting * brdfData.diffuse;
    }
    #endif

    #if defined(_ADDITIONAL_LIGHTS)
    // branch_if(IsAdditionalLightPixel())
    {
        brdfData.specular = lastSpecular;
        color += CalcAdditionalPBRLighting(brdfData,inputData,shadowMask);
        // return CalcAdditionalPBRLighting(brdfData,inputData,shadowMask).xyzx;
    }
    #endif

    return float4(color,surfaceData.alpha);
}

float4 _CalcPBR(SurfaceInputData data,Light mainLight,float4 shadowMask){
    SurfaceData surfaceData = data.surfaceData;
    InputData inputData = data.inputData;
    BRDFData brdfData;
    InitBRDFData(data,surfaceData.alpha/*inout*/,brdfData/*out*/);

    float3 worldPos = inputData.positionWS;
    float3 n = inputData.normalWS;
    float3 l = (mainLight.direction);
    float3 v = inputData.viewDirectionWS;
    float3 h = normalize(l+v);

    float lh = saturate(dot(l,h));
    float nh = saturate(dot(n,h));
    float nl = saturate(dot(n,l));
    float nv = saturate(dot(n,v));

    float roughness = brdfData.perceptualRoughness;
    float a = brdfData.roughness;
    float a2 =  brdfData.roughness2;

    float metallic = surfaceData.metallic;
    float smoothness = surfaceData.smoothness;
    float occlusion = surfaceData.occlusion;
    float3 albedo = surfaceData.albedo;
    float alpha = surfaceData.alpha;

    float2 screenUV = data.screenUV;

    float specTerm = 0;
    specTerm = MinimalistCookTorrance(nh,lh,a,a2);

    float3 radiance = _MainLightColor.xyz * (nl * mainLight.shadowAttenuation * mainLight.distanceAttenuation);

    float3 specColor = lerp(0.04,albedo,metallic);
    float3 diffColor = albedo.xyz * (1- metallic);
    float3 directColor = (diffColor + specColor * specTerm) * radiance;
// return float4(directColor.xyz,1);
// ------- gi
    float4 planarReflectTex = 0;
    #if defined(_PLANAR_REFLECTION_ON)
        planarReflectTex = SAMPLE_TEXTURE2D(_ReflectionTexture,sampler_ReflectionTexture,screenUV);
    #endif
    float3 giColor = 0;
    float3 giDiff = inputData.bakedGI * diffColor;
    float3 giSpec = CalcGISpec(unity_SpecCube0,samplerunity_SpecCube0,unity_SpecCube0_HDR,specColor,worldPos,n,v,0/*reflectDirOffset*/,1/*reflectIntensity*/
    ,nv,roughness,a2,smoothness,metallic,half2(0,1),1,planarReflectTex);

    giColor = (giDiff + giSpec) * occlusion;
// return giColor.xyzx;
    float4 col = 0;
    col.xyz = directColor + giColor;
    col.w = alpha;
    return col;
}

#endif //LIGHTING_HLSL