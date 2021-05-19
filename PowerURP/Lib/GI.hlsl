#if !defined(GI_HLSL)
#define GI_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float3 SampleLightmap(float2 lightmapUV){
    // #if defined(LIGHTMAP_ON)
    if(IsLightmapOn()){
        #if defined(UNITY_LIGHTMAP_FULL_HDR)
            bool encodedLightmap = false;
        #else
            bool encodedLightmap = true;
        #endif
        float4 decodeInstructions = float4(LIGHTMAP_HDR_MULTIPLIER,LIGHTMAP_HDR_EXPONENT,0,0);
        float4 transformUV = float4(1,1,0,0);
        return SampleSingleLightmap(TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP_NAME,LIGHTMAP_SAMPLER_NAME),lightmapUV,transformUV,encodedLightmap,decodeInstructions);
    }
    //endif
    return 0;
}
/**
    lerp(lightmap, sh ,t)
*/
float3 CalcLightmapAndSH(float3 normal,float2 lightmapUV,float t){
    float3 lightmap = SampleLightmap(lightmapUV);
    float3 sh = SampleSH(normal);
    return lerp(lightmap,sh,t);
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

float3 CalcGI(BRDFData brdfData,float3 bakedGI,float occlusion,float3 normal,float3 viewDir){
    float3 reflectDir = reflect(-viewDir,normal);
    float3 indirectDiffuse = bakedGI * occlusion * brdfData.diffuse;
    float3 indirectSpecular = CalcIBL(reflectDir,unity_SpecCube0,samplerunity_SpecCube0,brdfData.perceptualRoughness,occlusion);

    float3 fresnel = CalcFresnel(brdfData,normal,viewDir);
    float3 color = indirectDiffuse + indirectSpecular * fresnel;
    return color;
}


#endif // GI_HLSL