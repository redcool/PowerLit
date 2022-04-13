Shader "URP/PowerLit"
{
    Properties
    {
        [Header(MainTexture)]
        [MainTexture]_BaseMap("_BaseMap",2d) = "white"{}
        [gamma][MainColor][hdr]_Color("_Color",color) = (1,1,1,1)
        [Normal]_NormalMap("_NormalMap",2d) ="bump"{}
        _NormalScale("_NormalScale",float) = 1

        [Header(PBRMask)]
        _MetallicMaskMap("_MetallicMaskMap(Metallic(R),Smoothness(G),Occlusion(B))",2d) = "white"{}
        _Metallic("_Metallic",range(0,1)) = 0.5
        _Smoothness("_Smoothness",range(0,1)) = 0.5
        _Occlusion("_Occlusion",range(0,1)) = 0.5
        [Header(PBRMask Channel)]
        [Enum(R,0,G,1,B,2)]_MetallicChannel("_MetallicChannel",int) = 0
        [Enum(R,0,G,1,B,2)]_SmoothnessChannel("_SmoothnessChannel",int) = 1
        [Enum(R,0,G,1,B,2)]_OcclusionChannel("_OcclusionChannel",int) = 2

        [Header(Emission)]
        [ToggleOff]_EmissionOn("_EmissionOn",int) = 0
        _EmissionMap("_EmissionMap",2d) = "white"{}
        [hdr]_EmissionColor("_EmissionColor",Color) = (1,1,1,1)
        [Toggle]_BakeEmissionOn("_BakeEmissionOn",int) = 0

        [Header(Shadow)]
        [Toggle]_IsReceiveShadow("_IsReceiveShadow",int) = 1

        [Header(GI)]
        _LightmapSH("_LightmapSH",range(0,1)) = 0.5
        _LMSaturate("_LMSaturate",range(0,4)) = 1
        
        [Header(Custom IBL)]
        [Toggle]_IBLOn("_IBLOn",float) = 0
        [NoScaleOffset]_IBLCube("_IBLCube",cube) = ""{}
        _EnvIntensity("_EnvIntensity",float) = 1
        [Toggle]_IBLMaskMainTexA("_IBLMaskMainTexA",float) = 0
        _ReflectDirOffset("_ReflectDirOffset",vector) = (0,0,0,0)

        [Header(Custom Light)]
        [Toggle]_CustomLightOn("_CustomLightOn",float) = 0
        _CustomLightDir("_CustomLightDir",vector) = (0,1,0,0)
        _CustomLightColor("_CustomLightColor",color) = (0,0,0,0)

        [Header(Specular)]
        _FresnelIntensity("_FresnelIntensity",float) = 1

        [Header(Clip)]
        [Toggle]_ClipOn("_ClipOn",float) = 0
        _Cutoff("_Cutoff",range(0,1)) = 0.5

/**
    alpha : [srcAlpha][oneMinusSrcAlpha]
    premultiply : [one][oneMinusSrcAlpha]
    additive: [srcAlpha][one]
    multiply : [dstColor][zero]
*/
        [Header(Blend)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0

        [Header(Alpha Premulti)]
        [Toggle]_AlphaPremultiply("_AlphaPremultiply",int) = 0

        [Header(Depth)]
        [Toggle]_ZWrite("_ZWrite",int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("_ZTest",int) = 4

        [Header(Cull)]
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2

        [Header(Wind)]
        [Toggle]_WindOn("_WindOn (need vertex color.r)",float) = 0
        _WindAnimParam("_WindAnimParam(x:branch,edge,z : global offset,w:flutter offset)",vector) = (1,1,0.1,0.3)
        _WindDir("_WindDir,dir:(xyz),intensity:(w)",vector) = (1,0.1,0,1)

        [Header(Snow)]
        _SnowIntensity("_SnowIntensity",range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 100

        Pass
        {
            /*
            no dir lightmap
powerUrpLit
1 GI计算与Lit保持一致
2 shadowcaster算法保持一致
3 clip,blend,depth,cullMode暴露出来
4 shadow receiver
5 lightmap
6 shadow cascade 
7 multi lights(vertex,fragment)
8 shadowMask 

Todo:
multi lights shadows
detail map
wind
snow
rain
sphere fog
box projection



            */
            blend [_SrcMode][_DstMode]
            zwrite[_ZWrite]
            ztest[_ZTest]
            cull [_CullMode]
            // stencil{
            //     ref [_Ref]
            //     comp[_Comp]
            //     pass[_Pass]
            //     zfail[_ZFail]
            //     fail[_Fail]
            // }

            Name "ForwardLit"
            Tags{"LightMode"="UniversalForward"}
            HLSLPROGRAM
            // #pragma prefer_hlslcc gles
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile_fog

            #include "Lib/PowerLitInput.hlsl"
            #include "Lib/PowerLitForwardPass.hlsl"
            ENDHLSL
        }
        Pass{
            Name "ShadowCaster"
            Tags{"LightMode"="ShadowCaster"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Lib/PowerLitInput.hlsl"
            #include "Lib/ShadowCasterPass.hlsl"

            ENDHLSL
        }

        Pass{
            Name "DepthOnly"
            Tags{"LightMode"="DepthOnly"}
            zwrite on
            colorMask 0
            cull[_CullMode]
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Lib/PowerLitInput.hlsl"
            #include "Lib/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass{
            Name "Meta"
            Tags{"LightMode"="Meta"}
            cull off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Lib/PowerLitInput.hlsl"
            #include "Lib/PowerLitMetaPass.hlsl"
            ENDHLSL
        }

    }
    CustomEditor "PowerUtilities.PowerLitShaderGUI"
}
