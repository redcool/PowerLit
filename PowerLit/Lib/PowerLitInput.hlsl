#if !defined(POWER_LIT_INPUT_HLSL)
#define POWER_LIT_INPUT_HLSL

#include "PowerLitCommon.hlsl"

#include "PowerSurfaceInputData.hlsl"
#include "NatureLib.hlsl"
#include "ParallaxMapping.hlsl"
#include "FogLib.hlsl"


TEXTURE2D(_MetallicMask); SAMPLER(sampler_MetallicMask);
TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
TEXTURE2D(_MetallicMaskMap); SAMPLER(sampler_MetallicMaskMap);
TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
TEXTURECUBE(_IBLCube); SAMPLER(sampler_IBLCube);
TEXTURE2D(_ReflectionTex);SAMPLER(sampler_ReflectionTex); // planer reflection camera, use screenUV
TEXTURE2D(_ParallaxMap);SAMPLER(sampler_ParallaxMap);
TEXTURE2D(_RippleTex);SAMPLER(sampler_RippleTex);
TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);


#if !defined(INSTANCING_ON) || !defined(DOTS_INSTANCING_ON)
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _Color;

    float4 _NormalMap_ST;
    float _NormalScale;
    float _Metallic,_Smoothness,_Occlusion;
    int _MetallicChannel,_SmoothnessChannel,_OcclusionChannel;
    float _ClipOn;
    float _Cutoff;

    float _EmissionOn;
    float4 _EmissionColor;

    float _AlphaPremultiply;
    float _IsReceiveShadow;

    float _LightmapSH;
    float _LMSaturate;

    float _IBLOn;
    float _EnvIntensity;
    float _IBLMaskMainTexA;
    float4 _ReflectDirOffset;

    float _CustomLightOn;
    float4 _CustomLightDir;
    float4 _CustomLightColor;

    float _FresnelIntensity;

    float _WindOn;
    float4 _WindAnimParam;
    float4 _WindDir;
    float _WindSpeed;

    float _PlanarReflectionOn;

    float _SnowIntensity;
    float _FogOn;
    float _SphereFogOn;
    float _FogNoiseOn;

    float _ParallaxOn;
    float _ParallaxHeight;
    int _ParallaxMapChannel;

    int _RainRippleOn;
    float4 _RippleTex_ST;
    float _RippleSpeed;
    half _RippleSlopeAtten;
    half _RippleIntensity;

    half4 _RainColor;
    half _RainSmoothness,_RainMetallic;
CBUFFER_END

// #if (SHADER_LIBRARY_VERSION_MAJOR < 12)
// this block must define in UnityPerDraw cbuffer, change UnityInput.hlsl
// float4 unity_SpecCube0_BoxMax;          // w contains the blend distance
// float4 unity_SpecCube0_BoxMin;          // w contains the lerp value
// float4 unity_SpecCube0_ProbePosition;   // w is set to 1 for box projection
// float4 unity_SpecCube1_BoxMax;          // w contains the blend distance
// float4 unity_SpecCube1_BoxMin;          // w contains the sign of (SpecCube0.importance - SpecCube1.importance)
// float4 unity_SpecCube1_ProbePosition;   // w is set to 1 for box projection
// #endif

#endif
/**
#if defined(INSTANCING_ON)
    UNITY_INSTANCING_BUFFER_START(PropBuffer)
        UNITY_DEFINE_INSTANCED_PROP(float4,_BaseMap_ST)
        UNITY_DEFINE_INSTANCED_PROP(float4,_Color)
        UNITY_DEFINE_INSTANCED_PROP(float,_NormalScale)
        UNITY_DEFINE_INSTANCED_PROP(float,_Metallic)
        UNITY_DEFINE_INSTANCED_PROP(float,_Smoothness)
        UNITY_DEFINE_INSTANCED_PROP(float,_Occlusion)
        UNITY_DEFINE_INSTANCED_PROP(float,_MetallicChannel)
        UNITY_DEFINE_INSTANCED_PROP(float,_SmoothnessChannel)
        UNITY_DEFINE_INSTANCED_PROP(float,_OcclusionChannel)        
        UNITY_DEFINE_INSTANCED_PROP(float,_ClipOn)
        UNITY_DEFINE_INSTANCED_PROP(float,_Cutoff)
        UNITY_DEFINE_INSTANCED_PROP(float,_EmissionOn)
        UNITY_DEFINE_INSTANCED_PROP(float4,_EmissionColor)
        UNITY_DEFINE_INSTANCED_PROP(float,_AlphaPremultiply)
        UNITY_DEFINE_INSTANCED_PROP(float,_IsReceiveShadow)
        UNITY_DEFINE_INSTANCED_PROP(float,_LightmapSH)
        UNITY_DEFINE_INSTANCED_PROP(float,_IBLOn)
        UNITY_DEFINE_INSTANCED_PROP(float,_EnvIntensity) 
        UNITY_DEFINE_INSTANCED_PROP(float,_IBLMaskMainTexA) 
        UNITY_DEFINE_INSTANCED_PROP(float4,_ReflectDirOffset)
        UNITY_DEFINE_INSTANCED_PROP(float,_CustomLightOn)
        UNITY_DEFINE_INSTANCED_PROP(float4,_CustomLightDir)
        UNITY_DEFINE_INSTANCED_PROP(float4,_CustomLightColor)
        UNITY_DEFINE_INSTANCED_PROP(float,_WindOn)
        UNITY_DEFINE_INSTANCED_PROP(float4,_WindAnimParam)
        UNITY_DEFINE_INSTANCED_PROP(float4,_WindDir)
    UNITY_INSTANCING_BUFFER_END(PropBuffer)

    #define _BaseMap_ST UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_BaseMap_ST)
    #define _Color UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Color)
    #define _NormalScale UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_NormalScale)
    #define _Metallic UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Metallic)
    #define _Smoothness UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Smoothness)
    #define _Occlusion UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Occlusion)
    #define _MetallicChannel UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_MetallicChannel)
    #define _SmoothnessChannel UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_SmoothnessChannel)
    #define _OcclusionChannel UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_OcclusionChannel)    
    #define _ClipOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_ClipOn)
    #define _Cutoff UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_Cutoff)
    #define _EmissionOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_EmissionOn)
    #define _EmissionColor UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_EmissionColor)
    #define _AlphaPremultiply UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_AlphaPremultiply)
    #define _IsReceiveShadow UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_IsReceiveShadow)
    #define _LightmapSH UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_LightmapSH)
    #define _IBLOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_IBLOn)
    #define _EnvIntensity UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_EnvIntensity)
    #define _IBLMaskMainTexA UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_IBLMaskMainTexA)
    #define _ReflectDirOffset UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_ReflectDirOffset)
    #define _CustomLightOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_CustomLightOn)
    #define _CustomLightDir UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_CustomLightDir)
    #define _CustomLightColor UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_CustomLightColor)
    #define _WindOn UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_WindOn)
    #define _WindAnimParam UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_WindAnimParam)
    #define _WindDir UNITY_ACCESS_INSTANCED_PROP(PropBuffer,_WindDir)
#endif


// dots instancing
#if defined(DOTS_INSTANCING_ON)
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float4,_BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4,_Color)
    UNITY_DOTS_INSTANCED_PROP(float,_NormalScale)
    UNITY_DOTS_INSTANCED_PROP(float,_Metallic)
    UNITY_DOTS_INSTANCED_PROP(float,_Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float,_Occlusion)
    UNITY_DOTS_INSTANCED_PROP(float,_MetallicChannel)
    UNITY_DOTS_INSTANCED_PROP(float,_SmoothnessChannel)
    UNITY_DOTS_INSTANCED_PROP(float,_OcclusionChannel)

    UNITY_DOTS_INSTANCED_PROP(float,_ClipOn)
    UNITY_DOTS_INSTANCED_PROP(float,_Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float,_EmissionOn)
    UNITY_DOTS_INSTANCED_PROP(float4,_EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float,_AlphaPremultiply)
    UNITY_DOTS_INSTANCED_PROP(float,_IsReceiveShadow)
    UNITY_DOTS_INSTANCED_PROP(float,_LightmapSH)
    UNITY_DOTS_INSTANCED_PROP(float,_IBLOn)
    UNITY_DOTS_INSTANCED_PROP(float,_EnvIntensity)
    UNITY_DOTS_INSTANCED_PROP(float,_IBLMaskMainTexA)
    UNITY_DOTS_INSTANCED_PROP(float4,_ReflectDirOffset)
    UNITY_DOTS_INSTANCED_PROP(float,_CustomLightOn)
    UNITY_DOTS_INSTANCED_PROP(float4,_CustomLightDir)
    UNITY_DOTS_INSTANCED_PROP(float4,_CustomLightColor)
    UNITY_DOTS_INSTANCED_PROP(Float,_WindOn)
    UNITY_DOTS_INSTANCED_PROP(float4,_WindAnimParam)
    UNITY_DOTS_INSTANCED_PROP(float4,_WindDir)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Color UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4,Metadata__Color)
#define _NormalScale UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__NormalScale)
#define _Metallic UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__Metallic)
#define _Smoothness UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__Smoothness)
#define _Occlusion UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__Occlusion)
#define _MetallicChannel UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__MetallicChannel)
#define _SmoothnessChannel UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__SmoothnessChannel)
#define _OcclusionChannel UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__OcclusionChannel)
#define _ClipOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__ClipOn)
#define _Cutoff UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__Cutoff)
#define _EmissionOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__EmissionOn)
#define _EmissionColor UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4,Metadata__EmissionColor)
#define _AlphaPremultiply UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__AlphaPremultiply)
#define _IsReceiveShadow UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__IsReceiveShadow)
#define _LightmapSH UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__LightmapSH)
#define _IBLOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__IBLOnH)
#define _EnvIntensity UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__EnvIntensity)
#define _IBLMaskMainTexA UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__IBLMaskMainTexA)
#define _ReflectDirOffset UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__ReflectDirOffset)
#define _CustomLightOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__CustomLightOn)
#define _CustomLightDir UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__CustomLightDir)
#define _CustomLightColor UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__CustomLightColor)
#define _WindOn UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float,Metadata__WindOn)
#define _WindAnimParam UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4,Metadata__WindAnimParam)
#define _WindDir UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4,Metadata__WindDir)
#endif
*/



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
    branch_if(!_FogOn)
        return;

    branch_if(_SphereFogOn){
        BlendFogSphere(worldPos,sphereFogCoord,true,_FogNoiseOn,color.rgb/**/);
        return;
    }
    
    color.rgb = MixFog(color.rgb,unityFogCoord);
}

void ApplyRain(inout SurfaceData data,float2 screenUV,float3 worldNormal,float atten){
    if(!_RainRippleOn)
        return;

    float3 worldPos = ScreenToWorldPos(screenUV);
    float2 rippleUV = TRANSFORM_TEX(worldPos.xz,_RippleTex);
    half3 ripple = CalcRipple(_RippleTex,sampler_RippleTex,rippleUV,worldNormal,_RippleSlopeAtten,_RippleSpeed,_RippleIntensity);
    half rippleCol = saturate((ripple.x) * atten );

    // data.albedo = lerp(albedo,rippleCol.x,0.7);
    data.albedo = data.albedo * _RainColor +  rippleCol;
    data.metallic += _RainMetallic;
    data.smoothness += _RainSmoothness;
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
#endif //POWER_LIT_INPUT_HLSL