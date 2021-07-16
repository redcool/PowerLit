#if !defined(POWER_LIT_FORWARD_PASS_HLSL)
#define POWER_LIT_FORWARD_PASS_HLSL

#include "PowerLitInput.hlsl"
#include "Lighting.hlsl"

struct Attributes{
    float4 pos:POSITION;
    float3 normal:NORMAL;
    float4 color:COLOR;
    float4 tangent:TANGENT;
    float2 uv:TEXCOORD;
    float2 uv1 :TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings{
    float4 pos : SV_POSITION;
    float4 uv:TEXCOORD0; // xy : uv, zw: uv1 for lightmap uv
    // float uv1:TEXCOORD1; // sh,lightmap
    float4 tSpace0:TEXCOORD2;
    float4 tSpace1:TEXCOORD3;
    float4 tSpace2:TEXCOORD4;
    float4 vertexLightAndFogFactor:TEXCOORD5;
    float4 shadowCoord:TEXCOORD6;

    float4 color:COLOR;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};



Varyings vert(Attributes input){
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input,output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 worldPos = TransformObjectToWorld(input.pos);
    float3 worldNormal = TransformObjectToWorldNormal(input.normal);
    float sign = input.tangent.w * GetOddNegativeScale();
    float3 worldTangent = TransformObjectToWorldDir(input.tangent);
    float3 worldBinormal = cross(worldNormal,worldTangent)  * sign;
    output.tSpace0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
    output.tSpace1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
    output.tSpace2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

    output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);
    // OUTPUT_LIGHTMAP_UV(input.uv1,unity_LightmapST,output.uv1);
    output.uv.zw = input.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;

    float4 attenParam = input.color.x; // vertex color atten
    if(_WindOn){
        worldPos = WindAnimationVertex(worldPos/**/,input.pos,worldNormal,attenParam * _WindAnimParam,_WindDir + _GlobalWindDir);
    }

    float4 clipPos = TransformWorldToHClip(worldPos);

    float fogFactor = ComputeFogFactor(clipPos.z);
    float3 vertexLight = VertexLighting(worldPos,worldNormal,IsAdditionalLightVertex());
    output.vertexLightAndFogFactor = float4(vertexLight,fogFactor);


    output.pos = clipPos;
    output.shadowCoord = TransformWorldToShadowCoord(worldPos);
    output.color = attenParam;

    return output;
}

void InitInputData(Varyings input,SurfaceInputData siData,inout InputData data){
    float3 worldPos = float3(input.tSpace0.w,input.tSpace1.w,input.tSpace2.w);
    float3 normalTS = siData.surfaceData.normalTS;
    float3 normal = normalize(float3(
        dot(normalTS,input.tSpace0.xyz),
        dot(normalTS,input.tSpace1.xyz),
        dot(normalTS,input.tSpace2.xyz)
    ));

    data.positionWS = worldPos;
    data.normalWS = normal;
    data.viewDirectionWS = SafeNormalize(_WorldSpaceCameraPos - worldPos);
    data.shadowCoord = TransformWorldToShadowCoord(worldPos,input.shadowCoord); // transform to shadow or use input.shadowCoord

    data.fogCoord = input.vertexLightAndFogFactor.w;
    data.vertexLighting = input.vertexLightAndFogFactor.xyz;
    data.bakedGI = CalcLightmapAndSH(normal,input.uv.zw,siData.lightmapSH);
    data.normalizedScreenSpaceUV = (float2)0;
    data.shadowMask = SampleShadowMask(input.uv.zw);
}

float4 fragTest(Varyings input,SurfaceInputData data){
    InputData inputData = data.inputData;
    return input.color.w;
    // return input.uv.y;
    // return SampleLightmap(input.uv.zw).xyzx;
    // return MainLightRealtimeShadow(data.inputData.shadowCoord,true);
    return MainLightShadow(inputData.shadowCoord,inputData.positionWS,inputData.shadowMask,_MainLightOcclusionProbes,data.isReceiveShadow);
    // return SampleShadowMask(input.uv.zw).xyzx;
    // return SampleSH(float4(data.inputData.normalWS,1)).xyzx;
    // return data.inputData.bakedGI.xyzx;
    // return dot(CalcCascadeId(data.inputData.positionWS),0.25); // show cascade id
    // return data.inputData.vertexLighting.xyzx;
    return IsShadowMaskOn();
    return 0;
}

float4 frag(Varyings input):SV_Target{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    SurfaceInputData data = (SurfaceInputData)0;
    InitSurfaceInputData(input.uv,data/*inout*/);
    InitInputData(input,data,data.inputData/*inout*/);
// return fragTest(input,data);

    // float4 color = UniversalFragmentPBR(data.inputData,data.surfaceData);
    float4 color = CalcPBR(data);
    color.rgb = MixFog(color.rgb,data.inputData.fogCoord);
    // color.a = OutputAlpha(color.a,_SurfaceType)

    return color;
}

#endif //POWER_LIT_FORWARD_PASS_HLSL