#if !defined(POWER_LIT_CORE_HLSL)
#define POWER_LIT_CORE_HLSL

#include "PowerLitInput.hlsl"

#include "PowerSurfaceInputData.hlsl"
#include "NatureLib.hlsl"
#include "ParallaxMapping.hlsl"
#include "FogLib.hlsl"

void CalcAlbedo(TEXTURE2D_PARAM(mao,sampler_Map),float2 uv,float4 color,float cutoff,bool isClipOn,out float3 albedo,out float alpha ){
    float4 c = SAMPLE_TEXTURE2D(mao,sampler_Map,uv) * color;
    albedo = c.rgb;
    alpha = c.a;
    branch_if(isClipOn)
        clip(alpha - cutoff);
}

float3 CalcNormal(float2 uv,TEXTURE2D_PARAM(normalMap,sampler_normalMap),float scale){
    float4 c = SAMPLE_TEXTURE2D(normalMap,sampler_normalMap,uv);
    float3 n = UnpackNormalScale(c,scale);
    return n;
}

float3 CalcEmission(float2 uv,TEXTURE2D_PARAM(map,sampler_map),float3 emissionColor,float isEmissionOn){
    float4 emission = 0;
    branch_if(isEmissionOn){
        emission = SAMPLE_TEXTURE2D(map,sampler_map,uv);
        emission.xyz *= emissionColor;
    }
    return emission.xyz * emission.w;
}

void ApplyParallax(inout float2 uv,float3 viewTS){
    branch_if(_ParallaxOn){
        float height = SAMPLE_TEXTURE2D(_ParallaxMap,sampler_ParallaxMap,uv)[_ParallaxMapChannel];
        uv += ParallaxMapOffset(_ParallaxHeight,viewTS,height);
    }
    
}


float3 ScreenToWorldPos(float2 screenUV){
    float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV);
    return ScreenToWorldPos(screenUV,depth,unity_MatrixInvVP);
}

void ApplyFog(inout float4 color,float2 sphereFogCoord,float unityFogCoord,float3 worldPos){
    branch_if(!IsFogOn())
        return;

    branch_if(_SphereFogOn){
        BlendFogSphere(color.rgb/**/,worldPos,sphereFogCoord,true,_FogNoiseOn,_GlobalFogIntensity);
        return;
    }
    
    color.rgb = MixFog(color.rgb,unityFogCoord);
}

void ApplyRain(inout SurfaceData data,float2 screenUV,float3 worldNormal,float atten){
    branch_if(!IsRainOn())
        return;

    float3 worldPos = ScreenToWorldPos(screenUV);
    float2 rippleUV = TRANSFORM_TEX(worldPos.xz,_RippleTex);

    half3 ripple = CalcRipple(_RippleTex,sampler_RippleTex,rippleUV,worldNormal,_RippleSlopeAtten,_RippleSpeed,_RippleIntensity);
    half rippleCol = saturate((ripple.x) * atten ) * _GlobalRainIntensity;

    // data.albedo = lerp(albedo,rippleCol.x,0.7);
    half3 rainColor = lerp(1,_RainColor,_GlobalRainIntensity);
    data.albedo = data.albedo * rainColor +  rippleCol;
    data.metallic = saturate(data.metallic + _RainMetallic * _GlobalRainIntensity);
    data.smoothness = saturate(data.smoothness + _RainSmoothness * _GlobalRainIntensity);
}

void ApplySnow(inout SurfaceData data,half3 worldNormal){
    branch_if(! IsSnowOn())
        return;
    
    data.albedo = MixSnow(data.albedo,1,_SnowIntensity,worldNormal,_SnowUseNormalOnly);
}

void InitSurfaceData(float2 uv,inout SurfaceData data){
    // float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,uv);
    // data.alpha = CalcAlpha(baseMap.w,_Color.a,_Cutoff,_ClipOn);
    // data.albedo = baseMap.xyz * _Color.xyz;
    CalcAlbedo(_BaseMap,sampler_BaseMap,uv,_Color,_Cutoff,_ClipOn,data.albedo/*out*/,data.alpha/*out*/);

    float4 metallicMask = SAMPLE_TEXTURE2D(_MetallicMaskMap,sampler_MetallicMaskMap,uv);
    data.metallic = metallicMask[_MetallicChannel] * _Metallic;
    data.smoothness = metallicMask[_SmoothnessChannel] * _Smoothness;
    data.occlusion = lerp(1,metallicMask[_OcclusionChannel],_Occlusion);

    data.normalTS = CalcNormal( TRANSFORM_TEX(uv,_NormalMap),_NormalMap,sampler_NormalMap,_NormalScale);
    data.emission = CalcEmission(uv,_EmissionMap,sampler_EmissionMap,_EmissionColor.xyz,_EmissionOn);
    data.specular = (float3)0;
    data.clearCoatMask = 0;
    data.clearCoatSmoothness =1;

}

void InitSurfaceInputData(float2 uv,float4 clipPos,inout SurfaceInputData data){
    InitSurfaceData(uv,data.surfaceData /*inout*/);
    data.isAlphaPremultiply = _AlphaPremultiply;
    data.isReceiveShadow = _IsReceiveShadow && _MainLightShadowOn;
    data.lightmapSH = _LightmapSH;
    data.lmSaturate = _LMSaturate;

    data.screenUV = clipPos.xy/_ScreenParams.xy;
    branch_if(_PlanarReflectionOn)
        data.screenUV.x = 1- data.screenUV.x; // for planar reflection camera
}
#endif //POWER_LIT_CORE_HLSL