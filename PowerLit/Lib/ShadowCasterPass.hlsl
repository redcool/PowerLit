#if !defined(SHADOW_CASTER_PASS_HLSL)
#define SHADOW_CASTER_PASS_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "PowerLitCore.hlsl"

float3 _LightDirection;

struct Attributes{
    float4 pos:POSITION;
    float3 normal:NORMAL;
    float2 uv:TEXCOORD0;
    float3 color:COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings{
    float2 uv:TEXCOORD0;
    float4 pos:SV_POSITION;
};

float4 GetShadowPositionHClip(Attributes input)
{
    float3 positionWS = TransformObjectToWorld(input.pos.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.normal);
    
    float4 attenParam = input.color.x; // vertex color atten
    branch_if(IsWindOn()){
        positionWS = WindAnimationVertex(positionWS,input.pos.xyz,normalWS,attenParam * _WindAnimParam, _WindDir,_WindSpeed).xyz;
    }

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif

    return positionCS;
}


Varyings vert(Attributes input){
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);

    output.uv = TRANSFORM_TEX(input.uv,_BaseMap);
    output.pos = GetShadowPositionHClip(input);
    return output;
}

float4 frag(Varyings input):SV_Target{
    float4 mainTex = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv) * _Color;
    branch_if(_ClipOn)
        clip(mainTex.a - _Cutoff);
    
    return 0;
}

#endif //SHADOW_CASTER_PASS_HLSL