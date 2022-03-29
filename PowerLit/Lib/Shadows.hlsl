#if !defined(SHADOWS_HLSL)
#define SHADOWS_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

float CalcCascadeId(float3 positionWS){
    float3 fromCenter0 = positionWS - _CascadeShadowSplitSpheres0.xyz;
    float3 fromCenter1 = positionWS - _CascadeShadowSplitSpheres1.xyz;
    float3 fromCenter2 = positionWS - _CascadeShadowSplitSpheres2.xyz;
    float3 fromCenter3 = positionWS - _CascadeShadowSplitSpheres3.xyz;
    float4 distances2 = float4(dot(fromCenter0, fromCenter0), dot(fromCenter1, fromCenter1), dot(fromCenter2, fromCenter2), dot(fromCenter3, fromCenter3));

    half4 weights = half4(distances2 < _CascadeShadowSplitSphereRadii);
    return 4-dot(weights,1);
}

/**
    Retransform worldPos to shadowCoord when _MainLightShadowCascade is true
    otherwise use vertex shadow coord
*/
float4 TransformWorldToShadowCoord(float3 worldPos,float4 vertexShadowCoord){
    if(!_MainLightShadowCascadeOn)
        return vertexShadowCoord;

    float cascadeId = ComputeCascadeIndex(worldPos);
    float4 shadowCoord = mul(_MainLightWorldToShadow[cascadeId],float4(worldPos,1));
    return float4(shadowCoord.xyz,cascadeId);
}

real SampleShadowmapRealtime(TEXTURE2D_SHADOW_PARAM(ShadowMap, sampler_ShadowMap), float4 shadowCoord, ShadowSamplingData samplingData, half4 shadowParams, bool isPerspectiveProjection = true)
{
    // Compiler will optimize this branch away as long as isPerspectiveProjection is known at compile time
    if (isPerspectiveProjection)
        shadowCoord.xyz /= shadowCoord.w;

    real attenuation;
    real shadowStrength = shadowParams.x;
    real isSoftShadow = shadowParams.y;

    // TODO: We could branch on if this light has soft shadows (shadowParams.y) to save perf on some platforms.
    if(isSoftShadow){
        attenuation = SampleShadowmapFiltered(TEXTURE2D_SHADOW_ARGS(ShadowMap, sampler_ShadowMap), shadowCoord, samplingData);
    }else{
        // 1-tap hardware comparison
        attenuation = SAMPLE_TEXTURE2D_SHADOW(ShadowMap, sampler_ShadowMap, shadowCoord.xyz);
    }
    attenuation = LerpWhiteTo(attenuation, shadowStrength);

    // Shadow coords that fall out of the light frustum volume must always return attenuation 1.0
    // TODO: We could use branch here to save some perf on some platforms.
    return BEYOND_SHADOW_FAR(shadowCoord) ? 1.0 : attenuation;
}

float MainLightRealtimeShadow(float4 shadowCoord,bool isReceiveShadow){
    if(!isReceiveShadow)
        return 1;
    
    ShadowSamplingData samplingData = GetMainLightShadowSamplingData();
    float4 params = GetMainLightShadowParams();
    return SampleShadowmapRealtime(_MainLightShadowmapTexture,sampler_MainLightShadowmapTexture,shadowCoord,samplingData,params,false);
}

float MixShadow(float realtimeShadow,float bakedShadow,float shadowFade,bool isMixShadow){
    if(isMixShadow){
        return min(lerp(realtimeShadow,1,shadowFade),bakedShadow);
    }
    return lerp(realtimeShadow,bakedShadow,shadowFade);
}

half GetShadowFade1(float3 positionWS)
{
    float3 camToPixel = positionWS - _WorldSpaceCameraPos;
    float distanceCamToPixel2 = dot(camToPixel, camToPixel);

    half fade = saturate(distanceCamToPixel2 * _MainLightShadowParams.z + _MainLightShadowParams.w);
    // half fade = saturate(distanceCamToPixel2 * 0.4 + -9);
    return fade * fade;
}

float MainLightShadow(float4 shadowCoord,float3 worldPos,float4 shadowMask,float4 occlusionProbeChannels,bool isReceiveShadow){
    float realtimeShadow = MainLightRealtimeShadow(shadowCoord,isReceiveShadow);

    float bakedShadow = 1;
    bool isShadowMaskOn = IsShadowMaskOn();
    // #if defined(CALCULATE_BAKED_SHADOWS)
    if(isShadowMaskOn){
        bakedShadow = BakedShadow(shadowMask,occlusionProbeChannels);
    }
    // #endif

    float shadowFade = 1;
    if(isReceiveShadow){
        shadowFade = GetShadowFade1(worldPos);
    }
    
    if(IsMainLightShadowCascadeOn() && isShadowMaskOn){
        // shadowCoord.w represents shadow cascade index
        // in case we are out of shadow cascade we need to set shadow fade to 1.0 for correct blending
        // it is needed when realtime shadows gets cut to early during fade and causes disconnect between baked shadow
        shadowFade = shadowCoord.w == 4 ? 1.0h : shadowFade;
    }
    // #endif

    return MixShadow(realtimeShadow,bakedShadow,shadowFade,false);
}

float4 SampleShadowMask(float2 shadowMaskUV){
    /**
     unity_ShadowMask,samplerunity_ShadowMask,shadowMaskuv [], unity_LightmapIndex.x]
     */
     float4 mask = 1;
     if(IsLightmapOn() && IsShadowMaskOn()){
        mask = SAMPLE_TEXTURE2D_LIGHTMAP(SHADOWMASK_NAME,SHADOWMASK_SAMPLER_NAME,shadowMaskUV SHADOWMASK_SAMPLE_EXTRA_ARGS);
     }
    return mask;
}

float4 CalcShadowMask(InputData inputData){
    // #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    //     half4 shadowMask = inputData.shadowMask;
    // #elif !defined (LIGHTMAP_ON)
    //     half4 shadowMask = unity_ProbesOcclusion;
    // #else
    //     half4 shadowMask = half4(1, 1, 1, 1);
    // #endif

    float4 shadowMask = (float4)1;
    if(IsLightmapOn()){
        if(IsShadowMaskOn()){
            shadowMask = inputData.shadowMask;
        }else{
            shadowMask = unity_ProbesOcclusion;
        }
    }
    return shadowMask;
}

#endif //SHADOWS_HLSL