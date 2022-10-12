#if !defined(POWER_LIT_META_PASS_HLSL)
#define POWER_LIT_META_PASS_HLSL

// meta input
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Lighting.hlsl"

CBUFFER_START(UnityMetaPass)
// x = use uv1 as raster position
// y = use uv2 as raster position
bool4 unity_MetaVertexControl;

// x = return albedo
// y = return normal
bool4 unity_MetaFragmentControl;
CBUFFER_END

half unity_OneOverOutputBoost;
half unity_MaxOutputValue;
half unity_UseLinearSpace;

struct MetaInput{
    half3 albedo;
    half3 emission;
    half3 specularColor;
};

half4 CalcMetaPosition(half4 pos,half2 uv1,half2 uv2,half4 uv1ST,half4 uv2ST){
    branch_if(unity_MetaVertexControl.x){
        pos.xy = uv1 * uv1ST.xy + uv1ST.zw;
    }
    branch_if(unity_MetaVertexControl.y){
        pos.xy = uv2 * uv2ST.xy + uv2ST.zw;
    }
        pos.z = pos.z > 0 ? REAL_MIN : 0;
    return TransformWorldToHClip(pos.xyz);
}

half4 CalcMetaFragment(MetaInput input){
    half4 color = half4(0,0,0,0);
    branch_if(unity_MetaFragmentControl.x){
        color = half4(input.albedo,1);
        color.rgb = clamp(PositivePow(color.rgb,saturate(unity_OneOverOutputBoost)) ,0,unity_MaxOutputValue);
    }
    branch_if(unity_MetaFragmentControl.y){
        half3 emission= input.emission;
        branch_if(!unity_UseLinearSpace){
            emission = LinearToSRGB(emission);
        }
        color = half4(emission,1);
    }
    return color;
}

// meta lighting

struct Atributes{
    half4 vertex:POSITION;
    half2 uv:TEXCOORD0;
    half2 uv1:TEXCOORD1;
    half2 uv2:TEXCOORD2;
    half4 tangent:TANGENT;
};

struct Varyings
{
    half4 pos:SV_POSITION;
    half2 uv:TEXCOORD;
};


Varyings vert(Atributes input){
    Varyings output = (Varyings)0;

    output.uv = TRANSFORM_TEX(input.uv,_BaseMap);
    output.pos = CalcMetaPosition(input.vertex,input.uv1,input.uv2,unity_LightmapST,unity_DynamicLightmapST);
    return output;
}

half4 frag(Varyings input):SV_Target{
    SurfaceInputData surfaceInputData = (SurfaceInputData)0;
    InitSurfaceInputData(input.uv,input.pos,surfaceInputData/**/);

    BRDFData brdfData = (BRDFData)0;
    SurfaceData surfaceData = surfaceInputData.surfaceData;
    InitBRDFData(surfaceInputData,surfaceData.alpha/**/,brdfData);

    MetaInput metaInput = (MetaInput)0;
    metaInput.albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
    metaInput.specularColor = surfaceData.specular;
    metaInput.emission = surfaceData.emission;

    return CalcMetaFragment(metaInput);
}

#endif //POWER_LIT_META_PASS_HLSL