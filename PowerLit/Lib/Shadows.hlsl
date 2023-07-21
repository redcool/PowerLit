#if !defined(SHADOWS_HLSL)
#define SHADOWS_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#undef MAIN_LIGHT_CALCULATE_SHADOWS
#undef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
#undef ADDITIONAL_LIGHT_CALCULATE_SHADOWS

#if defined(_RECEIVE_SHADOWS_ON) || !defined(_RECEIVE_SHADOWS_OFF)
    #if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) || defined(_MAIN_LIGHT_SHADOWS_SCREEN)
        #define MAIN_LIGHT_CALCULATE_SHADOWS

        #if defined(_MAIN_LIGHT_SHADOWS) || (defined(_MAIN_LIGHT_SHADOWS_SCREEN) && !defined(_SURFACE_TYPE_TRANSPARENT))
            #define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
        #endif
    #endif

    #if defined(_ADDITIONAL_LIGHT_SHADOWS)
        #define ADDITIONAL_LIGHT_CALCULATE_SHADOWS
    #endif
#endif

#define AdditionalLightShadow AdditionalLightShadow1
#define MainLightShadow MainLightShadow1

float CalcCascadeId(float3 positionWS){
    float3 fromCenter0 = positionWS - _CascadeShadowSplitSpheres0.xyz;
    float3 fromCenter1 = positionWS - _CascadeShadowSplitSpheres1.xyz;
    float3 fromCenter2 = positionWS - _CascadeShadowSplitSpheres2.xyz;
    float3 fromCenter3 = positionWS - _CascadeShadowSplitSpheres3.xyz;
    float4 distances2 = float4(dot(fromCenter0, fromCenter0), dot(fromCenter1, fromCenter1), dot(fromCenter2, fromCenter2), dot(fromCenter3, fromCenter3));

    float4 weights = float4(distances2 < _CascadeShadowSplitSphereRadii);
    return 4-dot(weights,1);
}

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

real SampleShadowmapRealtime(TEXTURE2D_SHADOW_PARAM(ShadowMap, sampler_ShadowMap), float4 shadowCoord, ShadowSamplingData samplingData, float4 shadowParams, bool isPerspectiveProjection = true)
{
    // Compiler will optimize this branch away as long as isPerspectiveProjection is known at compile time
    branch_if (isPerspectiveProjection)
        shadowCoord.xyz /= shadowCoord.w;

    real attenuation;
    real shadowStrength = shadowParams.x;
    real isSoftShadow = shadowParams.y;

    // TODO: We could branch on if this light has soft shadows (shadowParams.y) to save perf on some platforms.
    #if defined(_SHADOWS_SOFT)
    // branch_if(isSoftShadow)
    {
        attenuation = SampleShadowmapFiltered(TEXTURE2D_SHADOW_ARGS(ShadowMap, sampler_ShadowMap), shadowCoord, samplingData);
    }
    #else
    {
        // 1-tap hardware comparison
        attenuation = SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, shadowCoord.xyz);
    }
    #endif
    attenuation = LerpWhiteTo(attenuation, shadowStrength);

    // Shadow coords that fall out of the light frustum volume must always return attenuation 1.0
    // TODO: We could use branch here to save some perf on some platforms.
    return BEYOND_SHADOW_FAR(shadowCoord) ? 1.0 : attenuation;
}

float MainLightRealtimeShadow(float4 shadowCoord,bool isReceiveShadow){
    float shadow = 1;
    // branch_if(isReceiveShadow)
    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    {
        ShadowSamplingData samplingData = GetMainLightShadowSamplingData();
        float4 params = GetMainLightShadowParams();
        shadow = SampleShadowmapRealtime(_MainLightShadowmapTexture,sampler_MainLightShadowmapTexture,shadowCoord,samplingData,params,false);
    }
    #endif
    return shadow;
}

float MixShadow(float realtimeShadow,float bakedShadow,float shadowFade,bool isMixShadow){
    if(isMixShadow)
    {
        return min(lerp(realtimeShadow,1,shadowFade),bakedShadow);
    }
    return lerp(realtimeShadow,bakedShadow,shadowFade);
}

float MixShadow(float realtimeShadow,float bakedShadow,float shadowFade){
    #if defined(LIGHTMAP_SHADOW_MIXING)
        return min(lerp(realtimeShadow,1,shadowFade),bakedShadow);
    #endif
    
    return lerp(realtimeShadow,bakedShadow,shadowFade);
}


float GetShadowFade1(float3 positionWS)
{
    float3 camToPixel = positionWS - _WorldSpaceCameraPos;
    float distanceCamToPixel2 = dot(camToPixel, camToPixel);

    float fade = saturate(distanceCamToPixel2 * _MainLightShadowParams.z + _MainLightShadowParams.w);
    // float fade = saturate(distanceCamToPixel2 * 0.4 + -9);
    return fade * fade;
}

float MainLightShadow1(float4 shadowCoord,float3 worldPos,float4 shadowMask,float4 occlusionProbeChannels){
    float realtimeShadow = MainLightRealtimeShadow(shadowCoord);
    float bakedShadow = 1;
    #if defined(CALCULATE_BAKED_SHADOWS)
    // branch_if(isShadowMaskOn)
    {
        bakedShadow = BakedShadow(shadowMask,occlusionProbeChannels);
    }
    #endif

    float shadowFade = 1;
    // branch_if(isReceiveShadow)
    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    {
        shadowFade = GetShadowFade1(worldPos);
    }
    #endif

    #if defined(SHADOWS_SHADOWMASK) && defined(_MAIN_LIGHT_SHADOWS_CASCADE)
    // branch_if(IsMainLightShadowCascadeOn())
    {
        // shadowCoord.w represents shadow cascade index
        // in case we are out of shadow cascade we need to set shadow fade to 1.0 for correct blending
        // it is needed when realtime shadows gets cut to early during fade and causes disconnect between baked shadow
        shadowFade = shadowCoord.w == 4 ? 1.0h : shadowFade;
    }
    #endif

    return MixShadow(realtimeShadow,bakedShadow,shadowFade,_Shadows_ShadowMaskOn);
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
    return MixShadow(realtimeShadow, bakedShadow, shadowFade);
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