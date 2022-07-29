#if !defined(GI_HLSL)
#define GI_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float3 SampleLightmap(float2 lightmapUV){
    // #if defined(LIGHTMAP_ON)
    float3 lmap = 0;
    branch_if(IsLightmapOn()){
        #if defined(UNITY_LIGHTMAP_FULL_HDR)
            bool encodedLightmap = false;
        #else
            bool encodedLightmap = true;
        #endif
        float4 decodeInstructions = float4(LIGHTMAP_HDR_MULTIPLIER,LIGHTMAP_HDR_EXPONENT,0,0);
        float4 transformUV = float4(1,1,0,0);
        lmap = SampleSingleLightmap(TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP_NAME,LIGHTMAP_SAMPLER_NAME),lightmapUV,transformUV,encodedLightmap,decodeInstructions);
    }
    //endif
    return lmap;
}
/**
    lerp(lmap, sh ,t)
*/
float3 CalcLightmapAndSH(float3 normal,float2 lightmapUV,float lightmapOrSH,float lmSaturate,float lmIntensity){
    float3 lmap = SampleLightmap(lightmapUV) * lmIntensity;
    lmap = lerp(Gray(lmap),lmap,lmSaturate);
    float3 sh = SampleSH(normal);
    return lerp(lmap,sh,lightmapOrSH);
}



float3 CalcFresnel(BRDFData brdfData,float3 normal,float3 viewDir){
    float nv = saturate(dot(normal,viewDir));
    float fresnelTerm = Pow4(1-nv);
    float surfaceReduction = 1/(brdfData.roughness2 +1); //roughness[0,1] -> [1,0.5]
    float3 fresnel = surfaceReduction * lerp(brdfData.specular,brdfData.grazingTerm,fresnelTerm);
    return fresnel;
}

float3 CalcIBL(float3 reflectDir,TEXTURECUBE_PARAM(cube,sampler_Cube),float perceptualRoughness,float occlusion){
    // float mip = (6 * perceptualRoughness * (1.7-0.7 * perceptualRoughness)); // r * (1.7-0.7r)
    float mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
    float4 encodeIBL = SAMPLE_TEXTURECUBE_LOD(cube,sampler_Cube,reflectDir,mip);
    #if defined(UNITY_USE_NATIVE_HDR) || defined(UNITY_DOTS_INSTANTING_ENABLED)
        float3 specGI = encodeIBL.rgb;
    #else // mobile
        float3 specGI = DecodeHDREnvironment(encodeIBL,unity_SpecCube0_HDR);
    #endif
    return specGI * occlusion;
    // return _GlossyEnvironmentColor.rgb * occlusion;
}

#if SHADER_LIBRARY_VERSION_MAJOR < 12
float3 BoxProjectedCubemapDirection(float3 reflectionWS, float3 positionWS, float4 cubemapPositionWS, float4 boxMin, float4 boxMax)
{
    // Is this probe using box projection?
    branch_if (cubemapPositionWS.w > 0.0f)
    {
        float3 boxMinMax = (reflectionWS > 0.0f) ? boxMax.xyz : boxMin.xyz;
        float3 rbMinMax = float3(boxMinMax - positionWS) / reflectionWS;

        float fa = float(min(min(rbMinMax.x, rbMinMax.y), rbMinMax.z));

        float3 worldPos = float3(positionWS - cubemapPositionWS.xyz);

        float3 result = worldPos + reflectionWS * fa;
        return result;
    }
    else
    {
        return reflectionWS;
    }
}
#endif

float3 CalcIBL(float3 reflectDir,float perceptualRoughness,float occlusion,float customIBLMask){
    branch_if(_IBLOn){
        reflectDir = normalize(reflectDir + _ReflectDirOffset.xyz);
        float3 iblColor = CalcIBL(reflectDir,_IBLCube,sampler_IBLCube,perceptualRoughness,occlusion) * _EnvIntensity;
        return  lerp(1, iblColor,customIBLMask);
    }else{
        return CalcIBL(reflectDir,unity_SpecCube0,samplerunity_SpecCube0,perceptualRoughness,occlusion);
    }
}

float3 CalcPlanerReflection(float2 uv){
    return SAMPLE_TEXTURE2D(_ReflectionTex,sampler_ReflectionTex,uv).xyz;
}

float3 CalcGI(BRDFData brdfData,float3 bakedGI,float occlusion,float3 normal,float3 viewDir,float customIBLMask,float3 worldPos,float2 screenUV){
    float3 indirectDiffuse = bakedGI * occlusion * brdfData.diffuse;

    float3 indirectSpecular = 0;
    branch_if(_PlanarReflectionOn){
        indirectSpecular = CalcPlanerReflection(screenUV);
    }else{
        float3 reflectDir = reflect(-viewDir,normal);

        #if (SHADER_LIBRARY_VERSION_MAJOR >= 12)
        reflectDir = BoxProjectedCubemapDirection(reflectDir,worldPos,unity_SpecCube0_ProbePosition,unity_SpecCube0_BoxMin,unity_SpecCube0_BoxMax);
        #endif

        indirectSpecular = CalcIBL(reflectDir,brdfData.perceptualRoughness,occlusion,customIBLMask);
    }

    float3 fresnel = CalcFresnel(brdfData,normal,viewDir);
    float3 color = indirectDiffuse + indirectSpecular * fresnel;
    return color;
}


#endif // GI_HLSL