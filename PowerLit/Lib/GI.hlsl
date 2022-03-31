#if !defined(GI_HLSL)
#define GI_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

half3 SampleLightmap(half2 lightmapUV){
    // #if defined(LIGHTMAP_ON)
    half3 lmap = 0;
    if(IsLightmapOn()){
        #if defined(UNITY_LIGHTMAP_FULL_HDR)
            bool encodedLightmap = false;
        #else
            bool encodedLightmap = true;
        #endif
        half4 decodeInstructions = half4(LIGHTMAP_HDR_MULTIPLIER,LIGHTMAP_HDR_EXPONENT,0,0);
        half4 transformUV = half4(1,1,0,0);
        lmap = SampleSingleLightmap(TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP_NAME,LIGHTMAP_SAMPLER_NAME),lightmapUV,transformUV,encodedLightmap,decodeInstructions);
        lmap = lerp(dot(half3(0.2,0.7,0.02),lmap),lmap,2);
        // lmap = lerp(0.5,lmap,2);
    }
    //endif
    return lmap;
}
/**
    lerp(lmap, sh ,t)
*/
half3 CalcLightmapAndSH(half3 normal,half2 lightmapUV,half lightmapOrSH,half lmSaturate){
    half3 lmap = SampleLightmap(lightmapUV);
    lmap = lerp(Gray(lmap),lmap,lmSaturate);

    half3 sh = SampleSH(normal);
    return lerp(lmap,sh,lightmapOrSH);
}



half3 CalcFresnel(BRDFData brdfData,half3 normal,half3 viewDir){
    half nv = saturate(dot(normal,viewDir));
    half fresnelTerm = Pow4(1-nv);
    half surfaceReduction = 1/(brdfData.roughness2 +1); //roughness[0,1] -> [1,0.5]
    half3 fresnel = surfaceReduction * lerp(brdfData.specular,brdfData.grazingTerm,fresnelTerm);
    return fresnel;
}

half3 CalcIBL(half3 reflectDir,TEXTURECUBE_PARAM(cube,sampler_Cube),half perceptualRoughness,half occlusion){
    // half mip = (6 * perceptualRoughness * (1.7-0.7 * perceptualRoughness)); // r * (1.7-0.7r)
    half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
    half4 encodeIBL = SAMPLE_TEXTURECUBE_LOD(cube,sampler_Cube,reflectDir,mip);
    #if defined(UNITY_USE_NATIVE_HDR) || defined(UNITY_DOTS_INSTANTING_ENABLED)
        half3 specGI = encodeIBL.rgb;
    #else // mobile
        half3 specGI = DecodeHDREnvironment(encodeIBL,unity_SpecCube0_HDR);
    #endif
    return specGI * occlusion;
    // return _GlossyEnvironmentColor.rgb * occlusion;
}

half3 CalcIBL(half3 reflectDir,half perceptualRoughness,half occlusion,half customIBLMask){
    if(_IBLOn){
        reflectDir = normalize(reflectDir + _ReflectDirOffset.xyz);
        half3 iblColor = CalcIBL(reflectDir,_IBLCube,sampler_IBLCube,perceptualRoughness,occlusion) * _EnvIntensity;
        return  lerp(1, iblColor,customIBLMask);
    }else{
        return CalcIBL(reflectDir,unity_SpecCube0,samplerunity_SpecCube0,perceptualRoughness,occlusion);
    }
}

half3 CalcGI(BRDFData brdfData,half3 bakedGI,half occlusion,half3 normal,half3 viewDir,half customIBLMask){
    half3 reflectDir = reflect(-viewDir,normal);
    half3 indirectDiffuse = bakedGI * occlusion * brdfData.diffuse;
    half3 indirectSpecular = CalcIBL(reflectDir,brdfData.perceptualRoughness,occlusion,customIBLMask);

    half3 fresnel = CalcFresnel(brdfData,normal,viewDir);
    half3 color = indirectDiffuse + indirectSpecular * fresnel;
    return color;
}


#endif // GI_HLSL