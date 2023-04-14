#if !defined(SHADOWS_HLSL)
#define SHADOWS_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

#define AdditionalLightShadow AdditionalLightShadow1


/**
    Retransform worldPos to shadowCoord when _MainLightShadowCascade is true
    otherwise use vertex shadow coord
*/
float4 TransformWorldToShadowCoord(float3 worldPos,float4 vertexShadowCoord){
    float4 shadowCoord = 0;
    #if ! defined(_MAIN_LIGHT_SHADOWS_CASCADE)
    // branch_if(!_MainLightShadowCascadeOn)
        shadowCoord = vertexShadowCoord;
    #else
    {
        float cascadeId = ComputeCascadeIndex(worldPos);
        shadowCoord = mul(_MainLightWorldToShadow[cascadeId],float4(worldPos,1));
        shadowCoord.w = cascadeId;
    }
    #endif
    return shadowCoord;
}






float AdditionalLightShadow1(int lightIndex, float3 positionWS, float3 lightDirection, float4 shadowMask, float4 occlusionProbeChannels)
{
    float realtimeShadow = AdditionalLightRealtimeShadow(lightIndex, positionWS, lightDirection);

#ifdef CALCULATE_BAKED_SHADOWS
    float bakedShadow = BakedShadow(shadowMask, occlusionProbeChannels);
#else
    float bakedShadow = float(1.0);
#endif

#ifdef ADDITIONAL_LIGHT_CALCULATE_SHADOWS
    float shadowFade = GetAdditionalLightShadowFade(positionWS);

#else
    float shadowFade = float(1.0);
#endif

    return MixRealtimeAndBakedShadows(realtimeShadow, bakedShadow, shadowFade);
}

Light GetAdditionalLight1(uint i, float3 positionWS, float4 shadowMask)
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




float4 SampleShadowMask(float2 shadowMaskUV){
    /**
     unity_ShadowMask,samplerunity_ShadowMask,shadowMaskuv [], unity_LightmapIndex.x]
     */
    float4 mask = 1;
    // branch_if(IsLightmapOn() && IsShadowMaskOn())
    #if defined(LIGHTMAP_ON) && defined(SHADOWS_SHADOWMASK)
    // if(IsShadowMaskOn())
    {
        mask = SAMPLE_TEXTURE2D_LIGHTMAP(SHADOWMASK_NAME,SHADOWMASK_SAMPLER_NAME,shadowMaskUV SHADOWMASK_SAMPLE_EXTRA_ARGS);
    }
    #endif
    return mask;
}

float4 CalcShadowMask(InputData inputData){
    #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
        float4 shadowMask = inputData.shadowMask;
    #elif !defined (LIGHTMAP_ON)
        float4 shadowMask = unity_ProbesOcclusion;
    #else
        float4 shadowMask = float4(1, 1, 1, 1);
    #endif

    // -------- only LINGHTMAP_ON 
    // #if defined(LIGHTMAP_ON)
    // float4 shadowMask = lerp(1,inputData.shadowMask, isShadowMaskOn);
    // #else
    // float4 shadowMask = unity_ProbesOcclusion;
    // #endif
    
    return shadowMask;
}

#endif //SHADOWS_HLSL