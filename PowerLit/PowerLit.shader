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

        [GroupHeader(Main,PBR Slider Options)]
        [GroupToggle(Main)]_InvertSmoothnessOn("_InvertSmoothnessOn",int) = 0

        [GroupHeader(Main,PBRMask Channel)]
        [GroupEnum(Main,R 0 G 1 B 2)]_MetallicChannel("_MetallicChannel",int) = 0
        [GroupEnum(Main,R 0 G 1 B 2)]_SmoothnessChannel("_SmoothnessChannel",int) = 1
        [GroupEnum(Main,R 0 G 1 B 2)]_OcclusionChannel("_OcclusionChannel",int) = 2

        [Group(Parallax)]
        [GroupToggle(Parallax,_PARALLAX)]_ParallaxOn("_ParallaxOn",int) = 0
        [GroupToggle(Parallax,_PARALLAX_IN_VS,run in vertex shader)]_ParallaxInVSOn("_ParallaxInVSOn",int) = 0
        [GroupItem(Parallax)]_ParallaxMap("_ParallaxMap",2d) = "white"{}
        [GroupEnum(Parallax,R 0 G 1 B 2 A 3)]_ParallaxMapChannel("_ParallaxMapChannel",int) = 3
        [GroupSlider(Parallax)]_ParallaxHeight("_ParallaxHeight",range(0.005,0.08)) = 0.01

        [Header(Emission)]
        [GroupToggle(,_EMISSION)]_EmissionOn("_EmissionOn",int) = 0
        [noscaleoffset]_EmissionMap("_EmissionMap(rgb:Color,a:Mask)",2d) = "white"{}
        [hdr]_EmissionColor("_EmissionColor",Color) = (1,1,1,1)
        // [GroupToggle]_BakeEmissionOn("_BakeEmissionOn",int) = 0

        [Header(Shadow)]
        [GroupToggle(,_RECEIVE_SHADOWS_ON)]_IsReceiveShadowOn("_IsReceiveShadowOn",int) = 1

        [Header(PlanarReflection)]
        [GroupToggle(,_PLANAR_REFLECTION_ON)]_PlanarReflectionOn("_PlanarReflectionOn",int) = 0
        
        [Header(Custom IBL)]
        [GroupToggle(_,_IBL_ON)]_IBLOn("_IBLOn",float) = 0
        [NoScaleOffset]_IBLCube("_IBLCube",cube) = ""{}
        [Header(IBL Params)]
        _EnvIntensity("_EnvIntensity",float) = 1
        [GroupToggle]_IBLMaskMainTexA("_IBLMaskMainTexA",float) = 0
        _ReflectDirOffset("_ReflectDirOffset",vector) = (0,0,0,0)

        [Header(Custom Light)]
        [GroupToggle(_,_CUSTOM_LIGHT_ON)]_CustomLightOn("_CustomLightOn",float) = 0
        _CustomLightDir("_CustomLightDir",vector) = (0,1,0,0)
        [hdr]_CustomLightColor("_CustomLightColor",color) = (0,0,0,0)

        [Header(Specular)]
        _FresnelIntensity("_FresnelIntensity",float) = 1

        [Header(GI)] // Final GI = PowerLITFeature GI + Additional
        _LightmapSHAdditional("_LightmapSHAdditional",range(-1,1)) = 0
        _LMSaturateAdditional("_LMSaturateAdditional",range(-1,1)) = 0
        _LMIntensityAdditional("_LMIntensityAdditional",range(-1,1)) = 0

        [Header(Clip)]
        [GroupToggle(,_ALPHATEST_ON)]_ClipOn("_ClipOn",float) = 0
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
        [GroupToggle(_,_ALPHA_PREMULTIPLY_ON)]_AlphaPremultiply("_AlphaPremultiply",int) = 0

        [Header(Depth)]
        [GroupToggle]_ZWrite("_ZWrite",int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("_ZTest",int) = 4

        [Header(Cull)]
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2

        [Header(Wind)]
        [GroupToggle(_,_WIND_ON)]_WindOn("_WindOn (need vertex color.r)",float) = 0
        [GroupVectorSlider(branch edge globalOffset flutterOffset,0_0.4 0_0.5 0_0.6 0_0.06)]_WindAnimParam("_WindAnimParam(x:branch,edge,z : global offset,w:flutter offset)",vector) = (1,1,0.1,0.3)
        [GroupVectorSlider(WindVector Intensity,0_1)]_WindDir("_WindDir,dir:(xyz),Intensity:(w)",vector) = (1,0.1,0,0.5)
        _WindSpeed("_WindSpeed",range(0,1)) = 0.3
  
        [Header(Snow)]
        [GroupToggle(_,_SNOW_ON)]_SnowOn("_SnowOn",int) = 0
        [GroupToggle]_ApplyEdgeOn("_ApplyEdgeOn",int) = 1
        _SnowIntensity("_SnowIntensity",range(0,1)) = 0

        [Header(Fog)]
        [GroupToggle()]_FogOn("_FogOn",int) = 1
        [GroupToggle(_,_DEPTH_FOG_NOISE_ON)]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(_)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(_)]_HeightFogOn("_HeightFogOn",int) = 1

        [Header(Rain Ripple)]
        [GroupToggle(_,_RAIN_ON)]_RainOn("_RainOn",int) = 0
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
        _RainHeight("_RainHeight",float) = 5

        [GroupToggle]_StoreyTilingOn("_StoreyTilingOn",int) = 0
        [GroupVectorSlider(_,NoiseTileX NoiseTileY LightOffPercent LightSwitchPercent,0_10 0_10 0_1 0_1)]_StoreyTilingInfo("_StoreyTilingInfo",vector) = (5,1,0.5,0.8)
        _StoreySwitchSpeed("_StoreySwitchSpeed",float) = 0
    } 
    SubShader
    {
/*
no dir lightmap
1 GI计算与Lit保持一致
2 shadowcaster
3 clip,blend,depth,cullMode暴露出来
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

            // #pragma multi_compile_instancing

            // material keywords
            #pragma shader_feature_local _PARALLAX 
            #pragma shader_feature_local _PARALLAX_IN_VS
            #pragma shader_feature_local _RECEIVE_SHADOWS_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _PLANAR_REFLECTION_ON
            #pragma shader_feature_local_fragment _IBL_ON
            #pragma shader_feature_local_fragment _CUSTOM_LIGHT_ON
            #pragma shader_feature_local_fragment _ALPHA_PREMULTIPLY_ON
            // #pragma shader_feature_local_fragment _HEIGHT_FOG_ON
            // #pragma shader_feature_local_fragment _DEPTH_FOG_ON
            #pragma shader_feature_local_fragment _DEPTH_FOG_NOISE_ON
            #pragma shader_feature_local _SNOW_ON
            #pragma shader_feature_local _WIND_ON
            #pragma shader_feature_local _RAIN_ON
            
            // urp keywords 
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            // unity keywords
            // #pragma multi_compile_fog
            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK // mixed light need open shadow, otherwise no shadowMask
            #pragma multi_compile _ LIGHTMAP_ON

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
            // #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma shader_feature_local_fragment _ALPHATEST_ON

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
            // #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma shader_feature_local_fragment _ALPHATEST_ON

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
