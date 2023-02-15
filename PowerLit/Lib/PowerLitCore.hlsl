#if !defined(POWER_LIT_CORE_HLSL)
#define POWER_LIT_CORE_HLSL

#include "PowerLitInput.hlsl"

#include "PowerSurfaceInputData.hlsl"
#include "../../PowerShaderLib/Lib/NatureLib.hlsl"
#include "../../PowerShaderLib/Lib/ParallaxMapping.hlsl"
#include "../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"

void CalcAlbedo(TEXTURE2D_PARAM(map,sampler_Map),float2 uv,float4 color,float cutoff,bool isClipOn,out float3 albedo,out float alpha ){
    float4 c = SAMPLE_TEXTURE2D(map,sampler_Map,uv) * color;
    albedo = c.rgb;
    alpha = c.a;

    // branch_if(isClipOn)
    #if defined(_ALPHATEST_ON)
        clip(alpha - cutoff);
    #endif
}

float3 CalcNormal(float2 uv,TEXTURE2D_PARAM(normalMap,sampler_normalMap),float scale){
    float4 c = SAMPLE_TEXTURE2D(normalMap,sampler_normalMap,uv);
    float3 n = UnpackNormalScale(c,scale);
    return n;
}

float3 CalcEmission(float2 uv,TEXTURE2D_PARAM(map,sampler_map),float3 emissionColor){
    float4 emission = 0;
    #if defined(_EMISSION)
    //branch_if(isEmissionOn)
    {
        emission = SAMPLE_TEXTURE2D(map,sampler_map,uv);
        emission.xyz *= emissionColor;
    }
    #endif
    return emission.xyz * emission.w;
}

void ApplyParallax(inout float2 uv,float3 viewTS){
    // branch_if(_ParallaxOn)
    {
        float height = SAMPLE_TEXTURE2D(_ParallaxMap,sampler_ParallaxMap,uv)[_ParallaxMapChannel];
        uv += ParallaxMapOffset(_ParallaxHeight,viewTS,height);
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

void ApplyFog(inout float4 color,float2 sphereFogCoord,float unityFogCoord,float3 worldPos){
    BlendFogSphere(color.rgb/**/,worldPos,sphereFogCoord,true,_FogNoiseOn);
    // color.rgb = MixFog(color.rgb,unityFogCoord);
}

float3 CalcRainColor(float3 worldPos,float3 worldNormal,float3 worldView,float atten,float3 albedo){
    // cross noise
    float noise = unity_gradientNoise(worldPos.xz * _RainCube_ST.xy + _GlobalWindDir.xz * _RainCube_ST.zw * _Time.y) + 0.5;
    noise += unity_gradientNoise(worldPos.xz * _RainCube_ST.xy + float2(_GlobalWindDir.x* - _Time.x,0) ) + 0.5;

    // float3 n = normalize(cross(ddy(worldPos),ddx(worldPos)));
    // float atten1 = saturate(dot(n,float3(0,1,0)));
    // reflect
    float3 reflectDir = reflect(-worldView,worldNormal);
    reflectDir += _RainReflectDirOffset + noise*1;
    float4 envColor = SAMPLE_TEXTURECUBE(_RainCube,sampler_RainCube,reflectDir);
    envColor.xyz = DecodeHDREnvironment(envColor,_RainCube_HDR);

    float3 reflectCol = envColor.xyz * _RainReflectIntensity ;

    // ripple
    float2 rippleUV = (worldPos.xz+noise.x*0.01) * _RippleTex_ST.xy + _RippleTex_ST.zw;
    float3 ripple = ComputeRipple(_RippleTex,sampler_RippleTex,frac(rippleUV),_Time.x * _RippleSpeed) * _RippleIntensity;
    float rippleCol = saturate((ripple.x) );
    
    // atten
    float heightAtten =  (worldPos.y < _RainHeight);
    float slopeAtten = dot(worldNormal,float3(0,1,0)) - _RainSlopeAtten;
    float reflectAtten = saturate(slopeAtten * heightAtten);

    float3 rainColor = _RainColor.xyz;
    rainColor += (reflectCol + rippleCol * atten) * reflectAtten /albedo; // so composite reflectCol and rippleCol
    return lerp(1,rainColor,_GlobalRainIntensity);
}

void ApplyRain(inout SurfaceData data,float3 worldPos,float3 worldNormal,float3 worldView,float atten){
    branch_if(!IsRainOn())
        return;

    // float3 worldPos = ScreenToWorldPos(screenUV);

    data.albedo = saturate(data.albedo * CalcRainColor(worldPos,worldNormal,worldView,atten,data.albedo));
    data.metallic = saturate(data.metallic + _RainMetallic * _GlobalRainIntensity);
    data.smoothness = saturate(data.smoothness + _RainSmoothness * _GlobalRainIntensity);
    // data.albedo = CalcRainColor(worldPos,worldNormal,worldView,atten,data.albedo);;
}

void ApplySurfaceBelow(inout SurfaceData data,float3 worldPos){
    float heightRate = saturate(worldPos.y -_SurfaceDepth);
    heightRate = smoothstep(0.02,0.1,heightRate);
    data.albedo *= lerp(_BelowColor.xyz,1,heightRate);
}

void ApplySnow(inout SurfaceData data,float3 worldNormal){
    branch_if(! IsSnowOn())
        return;
    
    data.albedo = MixSnow(data.albedo,1,_SnowIntensity,worldNormal,_ApplyEdgeOn);
}

void InitSurfaceData(float2 uv,inout SurfaceData data){
    // float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,uv);
    // data.alpha = CalcAlpha(baseMap.w,_Color.a,_Cutoff,_ClipOn);
    // data.albedo = baseMap.xyz * _Color.xyz;
    CalcAlbedo(_BaseMap,sampler_BaseMap,uv,_Color,_Cutoff,0,data.albedo/*out*/,data.alpha/*out*/);

    float4 pbrMask = SAMPLE_TEXTURE2D(_MetallicMaskMap,sampler_MetallicMaskMap,uv);
    SplitPbrMaskTexture(pbrMask,
        int3(_MetallicChannel,_SmoothnessChannel,_OcclusionChannel),
        float3(_Metallic,_Smoothness,_Occlusion),
        data.metallic/**/,data.smoothness/**/,data.occlusion/**/,
        _InvertSmoothnessOn
    );

    data.normalTS = CalcNormal( TRANSFORM_TEX(uv,_NormalMap),_NormalMap,sampler_NormalMap,_NormalScale);
    data.emission = CalcEmission(uv,_EmissionMap,sampler_EmissionMap,_EmissionColor.xyz);
    data.specular = (float3)0;
    data.clearCoatMask = 0;
    data.clearCoatSmoothness =0;

}

void InitSurfaceInputData(float2 uv,float4 clipPos,inout SurfaceInputData data){
    InitSurfaceData(uv,data.surfaceData /*inout*/);
    // data.isAlphaPremultiply = _AlphaPremultiply;
    // data.isReceiveShadow = _IsReceiveShadowOn && _MainLightShadowOn;

    data.screenUV = clipPos.xy/_ScreenParams.xy;
    #if defined(_PLANAR_REFLECTION_ON)
    // branch_if(_PlanarReflectionOn)
        data.screenUV.x = 1- data.screenUV.x; // for planar reflection camera
    #endif
}
#endif //POWER_LIT_CORE_HLSL