#if !defined(POWER_LIT_FORWARD_PASS_HLSL)
#define POWER_LIT_FORWARD_PASS_HLSL

#include "PowerLitCore.hlsl"
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
    float4 viewDirTS_NV:TEXCOORD7;

    float4 color:COLOR;
    float4 fogCoord:COLOR1;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings vert(Attributes input){
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input,output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 worldPos = TransformObjectToWorld(input.pos.xyz);
    float3 worldNormal = TransformObjectToWorldNormal(input.normal);

    float4 attenParam = input.color.x; // vertex color atten
    #if defined(_WIND_ON)
    branch_if(IsWindOn())
    {
        worldPos = WindAnimationVertex(worldPos,input.pos.xyz,worldNormal,attenParam * _WindAnimParam, _WindDir,_WindSpeed).xyz;
    }
    #endif

    float sign = input.tangent.w * GetOddNegativeScale();
    float3 worldTangent = TransformObjectToWorldDir(input.tangent.xyz);
    float3 worldBinormal = cross(worldNormal,worldTangent)  * sign;
    output.tSpace0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
    output.tSpace1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
    output.tSpace2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

    output.uv.xy = TRANSFORM_TEX(input.uv.xy,_BaseMap);
    
    // if(_StoreyTilingOn)
    #if defined(_STOREY_ON)
    {
        output.uv.y = WorldHeightTilingUV(worldPos);
    }
    #endif

    // OUTPUT_LIGHTMAP_UV(input.uv1,unity_LightmapST,output.uv1);
    output.uv.zw = input.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;

    float4 clipPos = TransformWorldToHClip(worldPos);

    // float fogFactor = ComputeFogFactor(clipPos.z);
    float3 vertexLight = VertexLighting(worldPos,worldNormal);
    output.vertexLightAndFogFactor = float4(vertexLight,0);
    output.pos = clipPos;
    output.shadowCoord = TransformWorldToShadowCoord(worldPos);
    output.color = attenParam;

    output.fogCoord.xy = CalcFogFactor(worldPos);

    // vertex noise
    float2 noiseUV = worldPos.xz*0.5 + _WindDir.xz * _Time.y * (_IsGlobalWindOn?_WindSpeed:0);
    // output.fogCoord.z = unity_gradientNoise(noiseUV);
    output.fogCoord.z = SampleWeatherNoiseLOD(noiseUV,0);

    // branch_if(_ParallaxOn)
    float3 viewDirWS = normalize(_WorldSpaceCameraPos - worldPos);
    output.viewDirTS_NV.w = saturate(dot(viewDirWS,worldNormal));
    #if defined(_PARALLAX) || defined(_IBL_ON)
    {
        output.viewDirTS_NV.xyz = (float3(
            dot(worldTangent,viewDirWS),
            dot(worldBinormal,viewDirWS),
            dot(worldNormal,viewDirWS)
        ));
        #if defined(_PARALLAX_IN_VS)
            ApplyParallaxVertex(output.uv.xy/**/,output.viewDirTS_NV.xyz);
        #endif
    }
    #endif

    return output;
}

void InitInputData(inout InputData data,float3 worldPos,Varyings input,SurfaceInputData siData){
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
    // data.fogCoord = input.vertexLightAndFogFactor.w;
    data.vertexLighting = input.vertexLightAndFogFactor.xyz;
    data.bakedGI = CalcLightmapAndSH(normal,input.uv.zw, (_LightmapSH + _LightmapSHAdditional),_LightmapSaturate + _LMSaturateAdditional,_LightmapIntensity+_LMIntensityAdditional);
    data.normalizedScreenSpaceUV = 0;
    data.shadowMask = SampleShadowMask(input.uv.zw);
}

float4 fragTest(Varyings input,SurfaceInputData data){
    InputData inputData = data.inputData;
    // return input.uv.y;
    // return SampleLightmap(input.uv.zw).xyzx;
    // return MainLightRealtimeShadow(data.inputData.shadowCoord,true);
    // return MainLightShadow(inputData.shadowCoord,inputData.positionWS,inputData.shadowMask,_MainLightOcclusionProbes);
    // return SampleSH(float4(data.inputData.normalWS,1)).xyzx;
    // return data.inputData.shadowMask.xyzx;
    // return dot(CalcCascadeId(data.inputData.positionWS),0.25); // show cascade id
    // return data.inputData.vertexLighting.xyzx;
    return 0;
}

float4 frag(Varyings input,
    out float4 outputNormal:SV_TARGET1
):SV_Target{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    // global vars
    float3 worldPos = float3(input.tSpace0.w,input.tSpace1.w,input.tSpace2.w);
    float3 vertexNormal = float3(input.tSpace0.z,input.tSpace1.z,input.tSpace2.z);
    float2 screenUV = input.pos.xy/_ScreenParams.xy;
    float vertexNoise = input.fogCoord.z;

    SurfaceInputData data = (SurfaceInputData)0;

    #if defined(_PARALLAX) && !defined(_PARALLAX_IN_VS)
        ApplyParallax(input.uv.xy/**/,input.viewDirTS_NV.xyz); // move to vs
    #endif

    InitSurfaceInputData(data/*inout*/,input.uv.xy,input.pos,input.viewDirTS_NV.xyz);

    #if defined(_RAIN_ON)
    // blend rain normalTS
    branch_if(IsRainOn())
    {
        InitSurfaceInputDataRain(data/**/,worldPos,vertexNormal);
        ApplyRainRipple(data/**/,worldPos);
    }
    #endif

    InitInputData(data.inputData/*inout*/,worldPos,input,data);
    #if defined(_DETAIL_ON)
        ApplyDetails(input.uv.xy,data/**/);
    #endif
// return fragTest(input,data);

    #if defined(_STOREY_ON)
    // if(_StoreyTilingOn)
    {
        ApplyStoreyEmission(data.surfaceData.emission/**/,data.surfaceData.alpha/**/,worldPos,input.uv.xy);
        ApplyStoreyLineEmission(data.surfaceData.emission/**/,worldPos,input.uv.xy,input.color,input.viewDirTS_NV.w);
    }
    #endif
    half upFaceAtten = 1 - saturate(dot(vertexNormal,half3(0,1,0)));

//  world emission
    ApplyWorldEmission(data.surfaceData.emission/**/,worldPos,upFaceAtten);

    branch_if(_EmissionScanLineOn)
    {
        ApplyWorldEmissionScanLine(data.surfaceData.emission/**/,worldPos);
    }


    #if defined(_SNOW_ON)
    ApplySnow(data.surfaceData/**/,data.inputData.normalWS);
    #endif
    
    // data.surfaceData.albedo += vertexNoise;
    // return data.surfaceData.albedo.xyzx;

    float4 shadowMask = CalcShadowMask(data.inputData);
    Light mainLight = GetMainLight(data,shadowMask);

    #if defined(_RAIN_ON)
        data.rainAtten *= (vertexNoise+0.5) ;//* (mainLight.shadowAttenuation+0.25);
        data.rainReflectDirOffset = (data.rainNoise + _RainReflectDirOffset) * data.rainAtten * _RainReflectIntensity;
        // apply rain pbr 
        ApplyRainPbr(data/**/);
    #endif

    ApplySurfaceBelow(data.surfaceData/**/,data.inputData.positionWS);

    #if defined(DEBUG_DISPLAY)
        half4 debugColor = half4(0,0,0,1);
        bool isBreak=0;
        debugColor.xyz = CalcDebugColor(
            isBreak/**/,
            data.surfaceData.albedo/**/,
            data.surfaceData.specular/**/,
            data.surfaceData.alpha,
            data.surfaceData.metallic/**/,
            data.surfaceData.smoothness/**/,
            data.surfaceData.occlusion/**/,
            data.surfaceData.emission/**/,
            data.inputData.normalWS/**/,
            data.surfaceData.normalTS/**/,
            data.screenUV,
            data.inputData.positionWS,
            input.tSpace0,
            input.tSpace1,
            input.tSpace2
        );
        if(isBreak)
            return debugColor;
    #endif 
    outputNormal = data.inputData.normalWS.xyzx;
    half4 color = CalcPBR(data,mainLight,shadowMask);

    // float4 screenColor = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV);
    // color.xyz += screenColor.x*5;

    ApplyFog(color/**/,data.inputData.positionWS,input.fogCoord.xy,upFaceAtten);
    return color;
}

#endif //POWER_LIT_FORWARD_PASS_HLSL