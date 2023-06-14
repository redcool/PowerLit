#if !defined(GI_HLSL)
#define GI_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float3 SampleLightmap(float2 lightmapUV){
    float3 lmap = 0;
    #if defined(UNITY_LIGHTMAP_FULL_HDR)
        bool encodedLightmap = false;
    #else
        bool encodedLightmap = true;
    #endif
    
    float4 decodeInstructions = float4(LIGHTMAP_HDR_MULTIPLIER,LIGHTMAP_HDR_EXPONENT,0,0);
    float4 transformUV = float4(1,1,0,0);
    lmap = SampleSingleLightmap(TEXTURE2D_LIGHTMAP_ARGS(LIGHTMAP_NAME,LIGHTMAP_SAMPLER_NAME),lightmapUV,transformUV,encodedLightmap,decodeInstructions);
    return lmap;
}
/**
    lerp(lmap, sh ,t)
*/
float3 CalcLightmapAndSH(float3 normal,float2 lightmapUV,float lightmapOrSH,float lmSaturate,float lmIntensity){
    
    #if defined(LIGHTMAP_ON)
    // branch_if(IsLightmapOn())
    {
        float3 lmap = 0;
        lmap = SampleLightmap(lightmapUV) * lmIntensity;
        lmap = lerp(Gray(lmap),lmap,lmSaturate);
        return lmap;
    }
    #else
        float3 sh = SampleSH(normal);
        return sh;
    #endif
    // return lerp(lmap,sh,lightmapOrSH);
}



float3 CalcFresnel(BRDFData brdfData,float3 normal,float3 viewDir){
    float nv = saturate(dot(normal,viewDir));
    float fresnelTerm = Pow4(1-nv);
    float surfaceReduction = 1/(brdfData.roughness2 +1); //roughness[0,1] -> [1,0.5]
    float3 fresnel = surfaceReduction * lerp(brdfData.specular,brdfData.grazingTerm,fresnelTerm);
    return fresnel;
}

float3 CalcIBL(float3 reflectDir,TEXTURECUBE_PARAM(cube,sampler_Cube),float perceptualRoughness,float4 hdrEncode){
    // float mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
    float mip = (6 * perceptualRoughness * (1.7-0.7 * perceptualRoughness)); // r * (1.7-0.7r)
    float4 encodeIBL = SAMPLE_TEXTURECUBE_LOD(cube,sampler_Cube,reflectDir,mip);
    #if defined(UNITY_USE_NATIVE_HDR) || defined(UNITY_DOTS_INSTANTING_ENABLED)
        float3 specGI = encodeIBL.rgb;
    #else // mobile
        float3 specGI = DecodeHDREnvironment(encodeIBL,hdrEncode);//_IBLCube_HDR,unity_SpecCube0_HDR
    #endif
    return specGI;
    // return _GlossyEnvironmentColor.rgb;
}


float3 CalcIBL(float3 reflectDir,float perceptualRoughness,float customIBLMask){

    float3 iblColor = 0;
    
    // branch_if(_IBLOn) 
    #if defined(_IBL_ON)
    {
        iblColor = CalcIBL(reflectDir,_IBLCube,sampler_IBLCube,perceptualRoughness,_IBLCube_HDR);
    }
    #else
    {
        iblColor =  CalcIBL(reflectDir,unity_SpecCube0,samplerunity_SpecCube0,perceptualRoughness,unity_SpecCube0_HDR);
    }
    #endif
    return lerp(1, iblColor,customIBLMask);
}

float4 CalcPlanerReflection(float2 suv){
    return SAMPLE_TEXTURE2D(_ReflectionTexture,sampler_ReflectionTexture,suv);
}

#define REFLECT_MODE_INTERIROR_MAP 1

float3 CalcGI(BRDFData brdfData,float3 bakedGI,float occlusion,float3 normal,float3 viewDir,float customIBLMask,float3 worldPos,SurfaceInputData data){
    float3 indirectDiffuse = bakedGI  * brdfData.diffuse;

    float3 reflectDir = 0;
    float rough = brdfData.perceptualRoughness;
    float2 uvRange = float2(_ReflectDirOffset.w,1 - _ReflectDirOffset.w);

    branch_if(_ReflectMode == REFLECT_MODE_INTERIROR_MAP){
        reflectDir = CalcInteriorMapReflectDir(data.viewDirTS,data.uv,uvRange);
        rough = lerp(0.5,rough,UVBorder(data.uv,uvRange));
    }else
        reflectDir = CalcReflectDir(worldPos,normal,viewDir);
    
    // apply offset
    reflectDir+=_ReflectDirOffset.xyz + data.rainReflectDirOffset;

    float3 indirectSpecular  = CalcIBL(reflectDir,rough,customIBLMask);
    // indirectSpecular = lerp(indirectSpecular,1,UVBorder(data.uv,float2(_ReflectDirOffset.w,1 - _ReflectDirOffset.w)));

    // branch_if(_PlanarReflectionOn)
    #if defined(_PLANAR_REFLECTION_ON)
    {
        float4 planarReflectColor = CalcPlanerReflection(data.screenUV+data.rainReflectDirOffset.xz);
        indirectSpecular = lerp(indirectSpecular,planarReflectColor.xyz,planarReflectColor.w);
    }
    #endif

    float3 fresnel = CalcFresnel(brdfData,normal,viewDir);
    float3 color = indirectDiffuse + indirectSpecular * fresnel * data.envIntensity ;
    color *= occlusion;
    return color;
}


#endif // GI_HLSL