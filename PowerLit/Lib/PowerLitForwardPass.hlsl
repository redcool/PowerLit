#if !defined(POWER_LIT_FORWARD_PASS_HLSL)
#define POWER_LIT_FORWARD_PASS_HLSL

#include "PowerLitInput.hlsl"
#include "Lighting.hlsl"

struct Attributes{
    half4 pos:POSITION;
    half3 normal:NORMAL;
    half4 color:COLOR;
    half4 tangent:TANGENT;
    half2 uv:TEXCOORD;
    half2 uv1 :TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings{
    half4 pos : SV_POSITION;
    half4 uv:TEXCOORD0; // xy : uv, zw: uv1 for lightmap uv
    // half uv1:TEXCOORD1; // sh,lightmap
    half4 tSpace0:TEXCOORD2;
    half4 tSpace1:TEXCOORD3;
    half4 tSpace2:TEXCOORD4;
    half4 vertexLightAndFogFactor:TEXCOORD5;
    half4 shadowCoord:TEXCOORD6;

    half4 color:COLOR;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};



Varyings vert(Attributes input){
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input,output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    half3 worldPos = TransformObjectToWorld(input.pos.xyz);
    half3 worldNormal = TransformObjectToWorldNormal(input.normal);
    half sign = input.tangent.w * GetOddNegativeScale();
    half3 worldTangent = TransformObjectToWorldDir(input.tangent.xyz);
    half3 worldBinormal = cross(worldNormal,worldTangent)  * sign;
    output.tSpace0 = half4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
    output.tSpace1 = half4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
    output.tSpace2 = half4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

    output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);
    // OUTPUT_LIGHTMAP_UV(input.uv1,unity_LightmapST,output.uv1);
    output.uv.zw = input.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;

    half4 attenParam = input.color.x; // vertex color atten
    if(_WindOn){
        worldPos = WindAnimationVertex(worldPos,input.pos.xyz,worldNormal,attenParam * _WindAnimParam, _WindDir).xyz;
    }

    half4 clipPos = TransformWorldToHClip(worldPos);

    half fogFactor = ComputeFogFactor(clipPos.z);
    half3 vertexLight = VertexLighting(worldPos,worldNormal,IsAdditionalLightVertex());
    output.vertexLightAndFogFactor = half4(vertexLight,fogFactor);


    output.pos = clipPos;
    output.shadowCoord = TransformWorldToShadowCoord(worldPos);
    output.color = attenParam;

    return output;
}

void InitInputData(Varyings input,SurfaceInputData siData,inout InputData data){
    half3 worldPos = half3(input.tSpace0.w,input.tSpace1.w,input.tSpace2.w);
    half3 normalTS = siData.surfaceData.normalTS;
    half3 normal = normalize(half3(
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
    data.bakedGI = CalcLightmapAndSH(normal,input.uv.zw,siData.lightmapSH,siData.lmSaturate);
    data.normalizedScreenSpaceUV = (half2)0;
    data.shadowMask = SampleShadowMask(input.uv.zw);
}

half4 fragTest(Varyings input,SurfaceInputData data){
    InputData inputData = data.inputData;
    return input.color.w;
    // return input.uv.y;
    // return SampleLightmap(input.uv.zw).xyzx;
    // return MainLightRealtimeShadow(data.inputData.shadowCoord,true);
    return MainLightShadow(inputData.shadowCoord,inputData.positionWS,inputData.shadowMask,_MainLightOcclusionProbes,data.isReceiveShadow);
    // return SampleShadowMask(input.uv.zw).xyzx;
    // return SampleSH(half4(data.inputData.normalWS,1)).xyzx;
    // return data.inputData.bakedGI.xyzx;
    // return dot(CalcCascadeId(data.inputData.positionWS),0.25); // show cascade id
    // return data.inputData.vertexLighting.xyzx;
    return IsShadowMaskOn();
    return 0;
}

half4 frag(Varyings input):SV_Target{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    SurfaceInputData data = (SurfaceInputData)0;
    InitSurfaceInputData(input.uv.xy,data/*inout*/);
    InitInputData(input,data,data.inputData/*inout*/);
// return fragTest(input,data);

    // half4 color = UniversalFragmentPBR(data.inputData,data.surfaceData);
    data.surfaceData.albedo = MixSnow(data.surfaceData.albedo,1,_SnowIntensity,data.inputData.normalWS);
    half4 color = CalcPBR(data);


    color.rgb = MixFog(color.rgb,data.inputData.fogCoord);
    // color.a = OutputAlpha(color.a,_SurfaceType)

    return color;
}

#endif //POWER_LIT_FORWARD_PASS_HLSL