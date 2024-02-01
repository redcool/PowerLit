#if !defined(POWER_LIT_CORE_HLSL)
#define POWER_LIT_CORE_HLSL

#include "PowerLitInput.hlsl"
#include "../../PowerShaderLib/Lib/NatureLib.hlsl"
#include "../../PowerShaderLib/Lib/ParallaxLib.hlsl"
#include "../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../PowerShaderLib/Lib/NoiseLib.hlsl"
#include "../../PowerShaderLib/URPLib/URP_MotionVectors.hlsl"
#include "../../PowerShaderLib/URPLib/Lighting.hlsl"

#include "../../PowerShaderLib/Lib/BSDF.hlsl"
#include "../../PowerShaderLib/Lib/ReflectionLib.hlsl"
#include "../../PowerShaderLib/Lib/SDF.hlsl"
#include "../../PowerShaderLib/Lib/MathLib.hlsl"
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/Lib/BigShadows.hlsl"
#include "../../PowerShaderLib/Lib/GILib.hlsl"
#include "../../PowerShaderLib/URPLib/URP_DebugDisplay.hlsl"

// #define SIMPLE_NOISE_TEX

void CalcAlbedo(TEXTURE2D_PARAM(map,sampler_Map),float2 uv,float4 color,float cutoff,bool isClipOn,out float3 albedo,out float alpha ){
    float4 c = SAMPLE_TEXTURE2D(map,sampler_Map,uv) * color;
    albedo = c.rgb;
    alpha = c.a;

    #if defined(ALPHA_TEST)
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
        emission.xyz = CalcEmission(emission,_EmissionColor.xyz,_EmissionColor.w);
    }
    #endif
    return emission.xyz ;
}

void ApplyWorldEmission(inout float3 emissionColor,float3 worldPos,float globalAtten){
    // #if defined(_EMISSION_HEIGHT_ON)
    branch_if(_EmissionHeightOn)
    {
        ApplyHeightEmission(emissionColor/**/,worldPos,globalAtten,_EmissionHeight.xy,_EmissionHeightColor);
    }
    // #endif
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
    ApplyParallax(uv/**/,viewTS,_ParallaxHeight,_ParallaxMapChannel,_ParallaxIterate);
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
    // #if defined(_DEPTH_FOG_NOISE_ON)
    branch_if(_FogNoiseOn)
    {
        float2 fogNoiseUV = (worldPos.xz+worldPos.yz) * _FogDirTiling.w+ _FogDirTiling.xz * _Time.y;
        fogNoise = SampleWeatherNoise(fogNoiseUV);
    }
    // #endif
    BlendFogSphere(color.rgb/**/,worldPos,sphereFogCoord,_HeightFogOn,fogNoise,_DepthFogOn,globalAtten);
}

void ApplyScreenShadow(inout half3 color,float2 screenUV){
    UNITY_BRANCH if(_ScreenShadowOn)
    {
        color *= SAMPLE_TEXTURE2D(_ScreenSpaceShadowmapTexture,sampler_ScreenSpaceShadowmapTexture,screenUV).x;
    }
}

void ApplySurfaceBelow(inout float3 albedo,float3 worldPos){
    #if defined(_SURFACE_BELOW_ON)
    branch_if(_SurfaceBelowOn)
    {
    float heightRate = saturate(worldPos.y -_SurfaceDepth);
    heightRate = smoothstep(0.02,0.1,heightRate);
    albedo *= lerp(_BelowColor.xyz,1,heightRate);
    }
    #endif
}

void ApplySnow(inout float3 albedo,float3 worldNormal,half alpha){
    #if defined(_SNOW_ON)
    branch_if(! IsSnowOn())
        return;
    half snowAtten = (_SnowIntensityUseMainTexA ? alpha : 1) * _SnowIntensity;
    albedo = MixSnow(albedo,1,snowAtten,worldNormal,_ApplyEdgeOn);
    #endif
}

void ApplyStoreyLineEmission(inout float3 emissionColor,float3 worldPos,float2 screenUV,float4 vertexColor,float nv){
    branch_if(_StoreyLineOn)
    {
        // storey line color
        half4 lineNoise = SAMPLE_TEXTURE2D(_StoreyLineNoiseMap,sampler_StoreyLineNoiseMap,screenUV);
        ApplyStoreyLineEmission(emissionColor/**/,lineNoise,worldPos,vertexColor,nv,_StoreyLineColor.xyz);
    }
}


void ApplyDetails(inout float metallic,inout float smoothness,inout float occlusion,float2 uv,float3 positionWS,float3 normalWS)
{
    #if defined(_DETAIL_ON)
    float4 pbrMask = 0;

    branch_if(_DetailWorldPosTriplanar)
    {
        pbrMask = TriplanarSample(_DetailPBRMaskMap,sampler_DetailPBRMaskMap,positionWS,normalWS,_DetailPBRMaskMap_ST);
    }else{
        // 1 plane sample
        uv = CalcWorldUV(positionWS,_DetailWorldPlaneMode,_DetailPBRMaskMap_ST);
        pbrMask = SAMPLE_TEXTURE2D(_DetailPBRMaskMap,sampler_DetailPBRMaskMap,uv);
    }
    half3 pbrMaskScale = half3(_DetailPBRMetallic,_DetailPBRSmoothness,_DetailPBROcclusion);
    half3 detailPbrMaskApplyRate = half3(_DetailPbrMaskApplyMetallic,_DetailPbrMaskApplySmoothness,_DetailPbrMaskApplyOcclusion);

    ApplyDetailPbrMask(metallic/**/,smoothness/**/,occlusion/**/,pbrMask,pbrMaskScale,detailPbrMaskApplyRate);
    #endif 
}


#endif //POWER_LIT_CORE_HLSL