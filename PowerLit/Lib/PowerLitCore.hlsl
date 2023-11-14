#if !defined(POWER_LIT_CORE_HLSL)
#define POWER_LIT_CORE_HLSL

#include "PowerLitInput.hlsl"

#include "PowerSurfaceInputData.hlsl"
#include "../../PowerShaderLib/Lib/NatureLib.hlsl"

#include "../../PowerShaderLib/Lib/ParallaxMapping.hlsl"
#include "../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../PowerShaderLib/Lib/NoiseLib.hlsl"
#include "../../PowerShaderLib/URPLib/URPDebugDisplay.hlsl"
#include "../../PowerShaderLib/URPLib/URP_MotionVectors.hlsl"
#include "../../PowerShaderLib/Lib/ReflectionLib.hlsl"
#include "../../PowerShaderLib/Lib/SDF.hlsl"
#include "../../PowerShaderLib/Lib/MathLib.hlsl"
// #define SIMPLE_NOISE_TEX

void CalcAlbedo(TEXTURE2D_PARAM(map,sampler_Map),float2 uv,float4 color,float cutoff,bool isClipOn,out float3 albedo,out float alpha ){
    float4 c = SAMPLE_TEXTURE2D(map,sampler_Map,uv) * color;
    albedo = c.rgb;
    alpha = c.a;

    #if defined(_ALPHATEST_ON)
        clip(alpha - cutoff);
    #endif
}

float3 CalcNormal(float2 uv,TEXTURE2D_PARAM(normalMap,sampler_normalMap),float scale){
    float4 c = SAMPLE_TEXTURE2D(normalMap,sampler_normalMap,uv);
    float3 n = UnpackNormalScale(c,scale);
    return n;
}

float3 CalcEmission(float2 uv,TEXTURE2D_PARAM(map,sampler_map)){
    float4 emission = 0;
    #if defined(_EMISSION)
    // UNITY_BRANCH if(_EmissionOn)
    {
        emission = SAMPLE_TEXTURE2D(map,sampler_map,uv);
        emission.xyz = emission.xyz * _EmissionColor * emission.w;
    }
    #endif
    return emission.xyz ;
}

void ApplyWorldEmission(inout float3 emissionColor,float3 worldPos,float globalAtten){
    #if defined(_EMISSION_HEIGHT_ON)
    // UNITY_BRANCH if(_EmissionHeightOn)
    {

    float maxHeight = length(float3(UNITY_MATRIX_M._12,UNITY_MATRIX_M._22,UNITY_MATRIX_M._32));
    maxHeight += _EmissionHeight.y; // apply height offset

    float rate = 1 - saturate((worldPos.y - _EmissionHeight.x)/ (maxHeight - _EmissionHeight.x +0.0001));
    rate *= globalAtten;
    // half4 heightEmission = _EmissionHeightColor * rate;
    half3 heightEmission = lerp(emissionColor.xyz,_EmissionHeightColor.xyz,rate);
    emissionColor = heightEmission ;
    }
    #endif
}

void ApplyWorldEmissionScanLine(inout float3 emissionColor,float3 worldPos){
    #if defined(_EMISSION_SCANLINE_ON)
    half3 rate = (worldPos - _EmissionScanLineMin)/(_EmissionScanLineMax - _EmissionScanLineMin);
    rate = abs(rate - _EmissionScanLineRange_Rate.z);
    rate = 1-smoothstep(_EmissionScanLineRange_Rate.x,_EmissionScanLineRange_Rate.y,rate);
    emissionColor += rate[_ScanLineAxis] * _EmissionScanLineColor.xyz;
    #endif
}

void ApplyParallax(inout float2 uv,float3 viewTS){
    float size = 1.0/_ParallaxIterate;
    // branch_if(_ParallaxOn)
    UNITY_LOOP for(int i=0;i<_ParallaxIterate;i++)
    {
        float height = SAMPLE_TEXTURE2D(_ParallaxMap,sampler_ParallaxMap,uv)[_ParallaxMapChannel];
        uv += ParallaxMapOffset(_ParallaxHeight,viewTS,height) * height * size;
    }
}

void ApplyParallaxVertex(inout float2 uv,float3 viewTS){
    // branch_if(_ParallaxOn)
    {
        float height = SAMPLE_TEXTURE2D_LOD(_ParallaxMap,sampler_ParallaxMap,uv,0)[_ParallaxMapChannel];
        uv += ParallaxMapOffset(_ParallaxHeight,viewTS,height);
    }
}

float3 ScreenToWorldPos(float2 screenUV){
    float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV).x;
    return ScreenToWorldPos(screenUV,depth,unity_MatrixInvVP);
}

void ApplyFog(inout float4 color,float3 worldPos,float2 sphereFogCoord,half globalAtten){
    float fogNoise = 0;
    #if defined(_DEPTH_FOG_NOISE_ON)
    // if(_FogNoiseOn)
    {
        float2 fogNoiseUV = (worldPos.xz+worldPos.yz) * _FogDirTiling.w+ _FogDirTiling.xz * _Time.y;
        fogNoise = SampleWeatherNoise(fogNoiseUV);
    }
    #endif
    BlendFogSphere(color.rgb/**/,worldPos,sphereFogCoord,_HeightFogOn,fogNoise,_DepthFogOn,globalAtten);
}

void ApplyScreenShadow(inout half3 color,float2 screenUV){
    UNITY_BRANCH if(_ScreenShadowOn)
    {
        color *= SAMPLE_TEXTURE2D(_ScreenSpaceShadowmapTexture,sampler_ScreenSpaceShadowmapTexture,screenUV).x;
    }
}

void ApplyCloudShadow(inout half3 color,float3 worldPos){
    #if defined(_CLOUD_SHADOW_ON)
    #define _CloudShadowIntensity _CloudShadowIntensityInfo.x
    #define _CloudShadowBaseIntensity _CloudShadowIntensityInfo.y
    // UNITY_BRANCH if(_CloudShadowOn)
    {
        float noise = CalcWorldNoise(worldPos,_CloudShadowTilingOffset,1) * _CloudShadowIntensityInfo;
        color = lerp(_CloudShadowColor,color ,saturate(noise) + _CloudShadowBaseIntensity);
    }
    #endif
}

#if defined(_RAIN_ON)

/**
    ApplyRainRipple

    change albedox
    change normalTS
*/
void ApplyRainRipple(inout SurfaceInputData data,float3 worldPos){
    branch_if(!_RippleIntensity)
        return;

    float2 rippleUV = CalcRippleUV(worldPos,_RippleTex_ST,_RippleOffsetAutoStop);
    float3 ripple = CalcRipple(_RippleTex,sampler_RippleTex,rippleUV,_RippleSpeed,_RippleIntensity);
    ripple *= data.rainAtten;
    // apply ripple color 
    data.surfaceData.albedo += ripple.x * _RippleAlbedoIntensity;

    // apply ripple blend normal
    data.surfaceData.normalTS += ripple * _RippleBlendNormal;
    // full version
    //data.surfaceData.normalTS = BlendNormal(data.surfaceData.normalTS,(data.surfaceData.normalTS+ ripple));
}

#endif // _RAIN_ON

void ApplySurfaceBelow(inout SurfaceData data,float3 worldPos){
    #if defined(_SURFACE_BELOW_ON)
    // UNITY_BRANCH if(_SurfaceBelowOn)
    {
    float heightRate = saturate(worldPos.y -_SurfaceDepth);
    heightRate = smoothstep(0.02,0.1,heightRate);
    data.albedo *= lerp(_BelowColor.xyz,1,heightRate);
    }
    #endif
}

void ApplySnow(inout SurfaceData data,float3 worldNormal){
    #if defined(_SNOW_ON)
    branch_if(! IsSnowOn())
        return;
    
    data.albedo = MixSnow(data.albedo,1,_SnowIntensity,worldNormal,_ApplyEdgeOn);
    #endif
}

void InitSurfaceData(float2 uv,inout SurfaceData data){
    // float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,uv);
    // data.alpha = CalcAlpha(baseMap.w,_Color.a,_Cutoff,_ClipOn);
    // data.albedo = baseMap.xyz * _Color.xyz;
    float3 albedo = 0;
    CalcAlbedo(_BaseMap,sampler_BaseMap,uv,_Color,_Cutoff,0,albedo/*out*/,data.alpha/*out*/);
    data.albedo += albedo;

    half4 pbrMask = SAMPLE_TEXTURE2D(_MetallicMaskMap,sampler_MetallicMaskMap,uv);
    SplitPbrMaskTexture(
        data.metallic/**/,data.smoothness/**/,data.occlusion/**/,
        pbrMask,
        // half3(_MetallicChannel,_SmoothnessChannel,_OcclusionChannel), // gen code use dot
        half3(0,1,2),
        half3(_Metallic,_Smoothness,_Occlusion),
        _InvertSmoothnessOn
    );

    data.normalTS += CalcNormal( TRANSFORM_TEX(uv,_NormalMap),_NormalMap,sampler_NormalMap,_NormalScale);
    
    data.emission = CalcEmission(uv,_EmissionMap,sampler_EmissionMap);
    data.specular = 0;
    data.clearCoatMask = 0;
    data.clearCoatSmoothness =0;

}

void InitSurfaceInputData(inout SurfaceInputData data,float2 uv,float4 clipPos,float3 viewDirTS=0,float4 vertexColor=1){
    InitSurfaceData(uv,data.surfaceData /*inout*/);
    data.surfaceData.albedo *= _AlbedoMulVertexColor? vertexColor : 1;

    data.isAlphaPremultiply = _AlphaPremultiply;
    // data.isReceiveShadow = _IsReceiveShadowOff && _MainLightShadowOn;
    data.screenUV = clipPos.xy/_ScaledScreenParams.xy;
    data.uv = uv;
    data.viewDirTS = viewDirTS;
    #if defined(_PLANAR_REFLECTION_ON)
        data.screenUV.x = _PlanarReflectionReverseUV ? 1- data.screenUV.x : data.screenUV.x; // for planar reflection camera
    #endif
    
    data.envIntensity = _EnvIntensity;
}

#if defined(_STOREY_ON)
float WorldHeightTilingUV(float3 worldPos){
    float v = floor(worldPos.y/_StoreyHeight);
    return v;
}

float NoiseSwitchLight(float2 quantifyNum,float lightOffIntensity){
    float n = N21(quantifyNum);
    return frac(smoothstep(lightOffIntensity,1,n));
}

void ApplyStoreyEmission(inout float3 emissionColor,inout float alpha,float3 worldPos,float2 uv){

    // float tn = N21(floor(_Time.x * _StoreyWindowInfo.x));
    // tn = smoothstep(_StoreyWindowInfo.w,1,tn);

    // float n = N21(floor(uv.xy*float2(5,2)) + tn);
    // n = smoothstep(_StoreyWindowInfo.z,1,n);

    // auto light swidth
    float tn = NoiseSwitchLight(round(_Time.x * _StoreyLightSwitchSpeed) , _StoreyWindowInfo.w);
    float n = NoiseSwitchLight(floor(uv.xy*_StoreyWindowInfo.xy) + tn,_StoreyWindowInfo.z);
    emissionColor *= n;

    branch_if(_StoreyLightOpaque)
        alpha = Luminance(emissionColor) > 0.1? 1 : alpha;
}
void ApplyStoreyLineEmission(inout float3 emissionColor,float3 worldPos,float2 screenUV,float4 vertexColor,float nv){
    branch_if(_StoreyLineOn)
    {
        // storey line color
        half4 lineNoise = SAMPLE_TEXTURE2D(_StoreyLineNoiseMap,sampler_StoreyLineNoiseMap,screenUV);
        // half lineNoise = InterleavedGradientNoise(screenUV);
        half atten = vertexColor.x * lineNoise.x * saturate(pow(1-nv,2));
        half3 lineColor = _StoreyLineColor.xyz * saturate(atten) ;

        emissionColor = lerp(emissionColor,lineColor,vertexColor.x>0.1);
        // emissionColor = vertexColor.x;// lineNoise.x ;
    }
}

#endif //_STOREY_ON

void ApplyDetails(inout float metallic,inout float smoothness,inout float occlusion,float2 uv,float3 positionWS,float3 normalWS)
{
    #if defined(_DETAIL_ON)
    float4 pbrMask = 0;

    UNITY_BRANCH if(_DetailWorldPosTriplanar)
    {
        pbrMask = TriplanarSample(_DetailPBRMaskMap,sampler_DetailPBRMaskMap,positionWS,normalWS,_DetailPBRMaskMap_ST);
    }else{
        // 1 plane sample
        float2 uvs[3] = {positionWS.xz,positionWS.xy,positionWS.yz};
            uv = _DetailUVUseWorldPos ? uvs[_DetailWorldPlaneMode] : uv;
        uv = uv * _DetailPBRMaskMap_ST.xy + _DetailPBRMaskMap_ST.zw;
        pbrMask = SAMPLE_TEXTURE2D(_DetailPBRMaskMap,sampler_DetailPBRMaskMap,uv);
    }
    SplitPbrMaskTexture(pbrMask.x/**/,pbrMask.y/**/,pbrMask.z/**/,pbrMask,int3(0,1,2),float3(_DetailPBRMetallic,_DetailPBRSmoothness,_DetailPBROcclusion));
    // remove high light flickers
    pbrMask.z = saturate(pbrMask.z);

    half3 lerpValue = lerp(half3(metallic,smoothness,occlusion),pbrMask.xyz,half3(_DetailPbrMaskApplyMetallic,_DetailPbrMaskApplySmoothness,_DetailPbrMaskApplyOcclusion));
    metallic = lerpValue.x;
    smoothness = lerpValue.y;
    occlusion = lerpValue.z;
    // metallic = lerp(metallic,pbrMask.x,_DetailPbrMaskApplyMetallic);
    // smoothness = lerp(smoothness,pbrMask.y,_DetailPbrMaskApplySmoothness);
    // occlusion = lerp(occlusion,pbrMask.z,_DetailPbrMaskApplyOcclusion);
    #endif 
}


#endif //POWER_LIT_CORE_HLSL