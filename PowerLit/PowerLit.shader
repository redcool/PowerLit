Shader "URP/PowerLit"
{
    Properties
    {
        [Group(Main)]
        [GroupHeader(Main,MainTexture)]
        [GroupItem(Main)][MainTexture]_BaseMap("_BaseMap",2d) = "white"{}
        [GroupItem(Main)][gamma][MainColor][hdr]_Color("_Color",color) = (1,1,1,1)

        [GroupHeader(Main,Surface Below)]
        [GroupItem(Main)]_SurfaceDepth("_SurfaceDepth",float) = -1
        [GroupItem(Main)]_BelowColor("_BelowColor",color) = (.5,.5,.5,1)

        [GroupHeader(Main,Normal)]
        [GroupItem(Main)][Normal]_NormalMap("_NormalMap",2d) ="bump"{}
        [GroupItem(Main)]_NormalScale("_NormalScale",range(0,5)) = 1

        [GroupHeader(Main,PBRMask)]
        [GroupItem(Main)]_MetallicMaskMap("_MetallicMaskMap(Metallic(R),Smoothness(G),Occlusion(B))",2d) = "white"{}
        [GroupItem(Main)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(Main)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(Main)]_Occlusion("_Occlusion",range(0,1)) = 0.5
        [GroupHeader(Main,PBRMask Channel)]
        [GroupEnum(Main,R 0 G 1 B 2)]_MetallicChannel("_MetallicChannel",int) = 0
        [GroupEnum(Main,R 0 G 1 B 2)]_SmoothnessChannel("_SmoothnessChannel",int) = 1
        [GroupEnum(Main,R 0 G 1 B 2)]_OcclusionChannel("_OcclusionChannel",int) = 2

        [Group(Parallax)]
        [GroupToggle(Parallax)]_ParallaxOn("_ParallaxOn",int) = 0
        [GroupItem(Parallax)]_ParallaxMap("_ParallaxMap",2d) = "white"{}
        [GroupEnum(Parallax,R 0 G 1 B 2 A 3)]_ParallaxMapChannel("_ParallaxMapChannel",int) = 3
        [GroupSlider(Parallax)]_ParallaxHeight("_ParallaxHeight",range(0.005,0.08)) = 0.01

        [Header(Emission)]
        [ToggleOff]_EmissionOn("_EmissionOn",int) = 0
        _EmissionMap("_EmissionMap(rgb:Color,a:Mask)",2d) = "white"{}
        [hdr]_EmissionColor("_EmissionColor",Color) = (1,1,1,1)
        // [GroupToggle]_BakeEmissionOn("_BakeEmissionOn",int) = 0

        [Header(Shadow)]
        [GroupToggle]_IsReceiveShadow("_IsReceiveShadow",int) = 1

        [Header(PlanarReflection)]
        [GroupToggle]_PlanarReflectionOn("_PlanarReflectionOn",int) = 0
        
        [Header(Custom IBL)]
        [GroupToggle]_IBLOn("_IBLOn",float) = 0
        [NoScaleOffset]_IBLCube("_IBLCube",cube) = ""{}
        _EnvIntensity("_EnvIntensity",float) = 1
        [GroupToggle]_IBLMaskMainTexA("_IBLMaskMainTexA",float) = 0
        _ReflectDirOffset("_ReflectDirOffset",vector) = (0,0,0,0)

        [Header(Custom Light)]
        [GroupToggle]_CustomLightOn("_CustomLightOn",float) = 0
        _CustomLightDir("_CustomLightDir",vector) = (0,1,0,0)
        _CustomLightColor("_CustomLightColor",color) = (0,0,0,0)

        [Header(Specular)]
        _FresnelIntensity("_FresnelIntensity",float) = 1

        [Header(Clip)]
        [GroupToggle]_ClipOn("_ClipOn",float) = 0
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
        [GroupToggle]_AlphaPremultiply("_AlphaPremultiply",int) = 0

        [Header(Depth)]
        [GroupToggle]_ZWrite("_ZWrite",int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("_ZTest",int) = 4

        [Header(Cull)]
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2

// [Group(g1)]
        [Header(Wind)]
        [GroupToggle]_WindOn("_WindOn (need vertex color.r)",float) = 0
        [GroupVectorSlider(branch edge globalOffset flutterOffset,0_0.4 0_0.5 0_0.6 0_0.06)]_WindAnimParam("_WindAnimParam(x:branch,edge,z : global offset,w:flutter offset)",vector) = (1,1,0.1,0.3)
        [GroupVectorSlider(WindVector Intensity,0_1)]_WindDir("_WindDir,dir:(xyz),Intensity:(w)",vector) = (1,0.1,0,0.5)
        _WindSpeed("_WindSpeed",range(0,1)) = 0.3
  
        [Header(Snow)]
        [GroupToggle]_SnowOn("_SnowOn",int) = 0
        [GroupToggle]_ApplyEdgeOn("_ApplyEdgeOn",int) = 1
        _SnowIntensity("_SnowIntensity",range(0,1)) = 0

        [Header(Fog)]
        [GroupToggle]_FogOn("_FogOn",int) = 1
        [GroupToggle]_FogNoiseOn("_FogNoiseOn",int) = 0

        [Header(Rain Ripple)]
        [GroupToggle]_RainOn("_RainOn",int) = 0
        _RippleTex("_RippleTex",2d)=""{}
        _RippleSpeed("_RippleSpeed",float) = 10
        _RippleIntensity("_RippleIntensity",range(0,2)) = 1
        [GroupToggle]_RippleBlendNormalOn("_RippleBlendNormalOn",int) = 0

        [Header(Env)]
        _RainColor("_RainColor",color) = (.5,.5,.5,1)
        _RainMetallic("_RainMetallic",range(0,0.5)) = 0.1
        _RainSmoothness("_RainSmoothness",range(0,0.5)) = 0.1
        [Header(Rain Atten)]
        _RainSlopeAtten("_RainSlopeAtten",range(0,1)) = 0.6

        [Header(RainReflect)]
        _RainCube("_RainCube",cube)=""{}
        _RainReflectDirOffset("_RainReflectDirOffset",vector) = (0,0,0,0)
        _RainReflectIntensity("_RainReflectIntensity",range(0,.1))=0.1
        _RainHeight("_RainHeight",float) = 0


    } 
    SubShader
    {
/*
no dir lightmap
powerUrpLit
1 GI?????????Lit????????????
2 shadowcaster
3 clip,blend,depth,cullMode????????????
4 shadow receiver
5 lightmap
6 shadow cascade 
7 multi lights(vertex,fragment)
8 shadowMask 
wind
snow
rain
sphere fog
box projection unity 2021

Todo:
multi lights shadows
detail map
*/
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 100

        Pass
        {
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

            #include "Lib/PowerLitCore.hlsl"
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

            #include "Lib/PowerLitCore.hlsl"

            #define SHADOW_PASS
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

            #include "Lib/PowerLitCore.hlsl"
            #include "Lib/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        // UsePass "Universal Render Pipeline/Lit/DEPTHNORMALS"

        Pass{
            Name "Meta"
            Tags{"LightMode"="Meta"}
            cull off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Lib/PowerLitCore.hlsl"
            #include "Lib/PowerLitMetaPass.hlsl"
            ENDHLSL
        }

    }
    CustomEditor "PowerUtilities.PowerLitShaderGUI"
}
