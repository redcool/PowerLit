#if !defined(SIMPLE_LIT_META_PASS)
#define SIMPLE_LIT_META_PASS

#define _BaseMap _MainTex
#include "../../PowerShaderLib/URPLib/MetaPass.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"

float4 frag(Varyings input):SV_Target{
    float2 mainUV = input.uv.xy;

    float4 pbrMask = tex2D(_PbrMask,mainUV);
    float metallic = 0;
    float smoothness =0;
    float occlusion =0;
    SplitPbrMaskTexture(metallic/**/,smoothness/**/,occlusion/**/,pbrMask,int3(0,1,2),float3(_Metallic,_Smoothness,_Occlusion),false);
    float roughness = 1-smoothness;

    float4 mainTex = tex2D(_MainTex, mainUV) * _Color;
    float3 albedo = mainTex.xyz;
    float alpha = mainTex.w;

    #if defined(ALPHA_TEST)
        clip(alpha - _Cutoff);
    #endif

    float3 specColor = lerp(0.04,albedo,metallic);
    float3 diffColor = albedo.xyz * (1- metallic);  
    float3 emissionColor = 0;

    #if defined(_EMISSION)
        float3 emissionColor = CalcEmission(tex2D(_EmissionMap,mainUV),_EmissionColor.xyz,_EmissionColor.w);
    #endif

    MetaInput metaInput = (MetaInput)0;
    metaInput.albedo = diffColor + specColor * roughness * 0.5;
    metaInput.emission = emissionColor;

    return CalcMetaFragment(metaInput);
}

#endif //SIMPLE_LIT_META_PASS