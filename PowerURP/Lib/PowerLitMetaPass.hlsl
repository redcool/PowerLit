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

float unity_OneOverOutputBoost;
float unity_MaxOutputValue;
float unity_UseLinearSpace;

struct MetaInput{
    float3 albedo;
    float3 emission;
    float3 specularColor;
};

float4 CalcMetaPosition(float4 pos,float2 uv1,float2 uv2,float4 uv1ST,float4 uv2ST){
    if(unity_MetaVertexControl.x){
        pos.xy = uv1 * uv1ST.xy + uv1ST.zw;
    }
    if(unity_MetaVertexControl.y){
        pos.xy = uv2 * uv2ST.xy + uv2ST.zw;
    }
        pos.z = pos.z > 0 ? REAL_MIN : 0;
    return TransformWorldToHClip(pos.xyz);
}

float4 CalcMetaFragment(MetaInput input){
    float4 color = float4(0,0,0,0);
    if(unity_MetaFragmentControl.x){
        color = float4(input.albedo,1);
        color.rgb = clamp(PositivePow(color.rgb,saturate(unity_OneOverOutputBoost)) ,0,unity_MaxOutputValue);
    }
    if(unity_MetaFragmentControl.y){
        float3 emission= input.emission;
        if(!unity_UseLinearSpace){
            emission = LinearToSRGB(emission);
        }
        color = float4(emission,1);
    }
    return color;
}

// meta lighting

struct Atributes{
    float4 vertex:POSITION;
    float2 uv:TEXCOORD0;
    float2 uv1:TEXCOORD1;
    float2 uv2:TEXCOORD2;
    float4 tangent:TANGENT;
};

struct Varyings
{
    float4 pos:SV_POSITION;
    float2 uv:TEXCOORD;
};


Varyings vert(Atributes input){
    Varyings output = (Varyings)0;

    output.uv = TRANSFORM_TEX(input.uv,_BaseMap);
    output.pos = CalcMetaPosition(input.vertex,input.uv1,input.uv2,unity_LightmapST,unity_DynamicLightmapST);
    return output;
}

float4 frag(Varyings input):SV_Target{
    SurfaceInputData surfaceInputData = (SurfaceInputData)0;
    InitSurfaceInputData(input.uv,surfaceInputData/**/);

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