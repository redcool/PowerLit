#if !defined(SHADOW_CASTER_PASS_HLSL)
#define SHADOW_CASTER_PASS_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

half3 _LightDirection;

struct Attributes{
    half4 pos:POSITION;
    half3 normal:NORMAL;
    half2 uv:TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings{
    half2 uv:TEXCOORD0;
    half4 pos:SV_POSITION;
};

half4 GetShadowPositionHClip(Attributes input)
{
    half3 positionWS = TransformObjectToWorld(input.pos.xyz);
    half3 normalWS = TransformObjectToWorldNormal(input.normal);

    half4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

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

half4 frag(Varyings input):SV_Target{
    half4 mainTex = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv) * _Color;
    branch_if(_ClipOn)
        clip(mainTex.a - _Cutoff);
    
    return 0;
}

#endif //SHADOW_CASTER_PASS_HLSL