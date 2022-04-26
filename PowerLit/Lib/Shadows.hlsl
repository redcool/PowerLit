#if !defined(SHADOWS_HLSL)
#define SHADOWS_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

half CalcCascadeId(half3 positionWS){
    half3 fromCenter0 = positionWS - _CascadeShadowSplitSpheres0.xyz;
    half3 fromCenter1 = positionWS - _CascadeShadowSplitSpheres1.xyz;
    half3 fromCenter2 = positionWS - _CascadeShadowSplitSpheres2.xyz;
    half3 fromCenter3 = positionWS - _CascadeShadowSplitSpheres3.xyz;
    half4 distances2 = half4(dot(fromCenter0, fromCenter0), dot(fromCenter1, fromCenter1), dot(fromCenter2, fromCenter2), dot(fromCenter3, fromCenter3));

    half4 weights = half4(distances2 < _CascadeShadowSplitSphereRadii);
    return 4-dot(weights,1);
}

/**
    Retransform worldPos to shadowCoord when _MainLightShadowCascade is true
    otherwise use vertex shadow coord
*/
half4 TransformWorldToShadowCoord(half3 worldPos,half4 vertexShadowCoord){
    branch_if(!_MainLightShadowCascadeOn)
        return vertexShadowCoord;

    half cascadeId = ComputeCascadeIndex(worldPos);
    half4 shadowCoord = mul(_MainLightWorldToShadow[cascadeId],half4(worldPos,1));
    return half4(shadowCoord.xyz,cascadeId);
}

real SampleShadowmapRealtime(TEXTURE2D_SHADOW_PARAM(ShadowMap, sampler_ShadowMap), half4 shadowCoord, ShadowSamplingData samplingData, half4 shadowParams, bool isPerspectiveProjection = true)
{
    // Compiler will optimize this branch away as long as isPerspectiveProjection is known at compile time
    branch_if (isPerspectiveProjection)
        shadowCoord.xyz /= shadowCoord.w;

    real attenuation;
    real shadowStrength = shadowParams.x;
    real isSoftShadow = shadowParams.y;

    // TODO: We could branch on if this light has soft shadows (shadowParams.y) to save perf on some platforms.
    branch_if(isSoftShadow){
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

half MainLightRealtimeShadow(half4 shadowCoord,bool isReceiveShadow){
    branch_if(!isReceiveShadow)
        return 1;
    
    ShadowSamplingData samplingData = GetMainLightShadowSamplingData();
    half4 params = GetMainLightShadowParams();
    return SampleShadowmapRealtime(_MainLightShadowmapTexture,sampler_MainLightShadowmapTexture,shadowCoord,samplingData,params,false);
}

half MixShadow(half realtimeShadow,half bakedShadow,half shadowFade,bool isMixShadow){
    branch_if(isMixShadow){
        return min(lerp(realtimeShadow,1,shadowFade),bakedShadow);
    }
    return lerp(realtimeShadow,bakedShadow,shadowFade);
}

half GetShadowFade1(half3 positionWS)
{
    half3 camToPixel = positionWS - _WorldSpaceCameraPos;
    half distanceCamToPixel2 = dot(camToPixel, camToPixel);

    half fade = saturate(distanceCamToPixel2 * _MainLightShadowParams.z + _MainLightShadowParams.w);
    // half fade = saturate(distanceCamToPixel2 * 0.4 + -9);
    return fade * fade;
}

half MainLightShadow(half4 shadowCoord,half3 worldPos,half4 shadowMask,half4 occlusionProbeChannels,bool isReceiveShadow){
    half realtimeShadow = MainLightRealtimeShadow(shadowCoord,isReceiveShadow);

    half bakedShadow = 1;
    bool isShadowMaskOn = IsShadowMaskOn();
    // #branch_if defined(CALCULATE_BAKED_SHADOWS)
    branch_if(isShadowMaskOn){
        bakedShadow = BakedShadow(shadowMask,occlusionProbeChannels);
    }
    // #endif

    half shadowFade = 1;
    branch_if(isReceiveShadow){
        shadowFade = GetShadowFade1(worldPos);
    }
    
    branch_if(IsMainLightShadowCascadeOn() && isShadowMaskOn){
        // shadowCoord.w represents shadow cascade index
        // in case we are out of shadow cascade we need to set shadow fade to 1.0 for correct blending
        // it is needed when realtime shadows gets cut to early during fade and causes disconnect between baked shadow
        shadowFade = shadowCoord.w == 4 ? 1.0h : shadowFade;
    }
    // #endif

    return MixShadow(realtimeShadow,bakedShadow,shadowFade,false);
}

half4 SampleShadowMask(half2 shadowMaskUV){
    /**
     unity_ShadowMask,samplerunity_ShadowMask,shadowMaskuv [], unity_LightmapIndex.x]
     */
     half4 mask = 1;
     branch_if(IsLightmapOn() && IsShadowMaskOn()){
        mask = SAMPLE_TEXTURE2D_LIGHTMAP(SHADOWMASK_NAME,SHADOWMASK_SAMPLER_NAME,shadowMaskUV SHADOWMASK_SAMPLE_EXTRA_ARGS);
     }
    return mask;
}

half4 CalcShadowMask(InputData inputData){
    // #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    //     half4 shadowMask = inputData.shadowMask;
    // #elif !defined (LIGHTMAP_ON)
    //     half4 shadowMask = unity_ProbesOcclusion;
    // #else
    //     half4 shadowMask = half4(1, 1, 1, 1);
    // #endif

    half4 shadowMask = (half4)1;
    branch_if(IsLightmapOn()){
        branch_if(IsShadowMaskOn()){
            shadowMask = inputData.shadowMask;
        }else{
            shadowMask = unity_ProbesOcclusion;
        }
    }
    return shadowMask;
}

#endif //SHADOWS_HLSL