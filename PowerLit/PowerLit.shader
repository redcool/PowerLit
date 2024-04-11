Shader "URP/PowerLit"
{
    Properties
    {
//================================================= Main        
        [Group(Main)]
        [GroupHeader(Main,MainTexture)]
        [GroupItem(Main)][MainTexture]_BaseMap("_BaseMap",2d) = "white"{}
        [GroupItem(Main)][gamma][MainColor][hdr]_Color("_Color",color) = (1,1,1,1)
        [GroupToggle(Main)] _AlbedoMulVertexColor("_AlbedoMulVertexColor",float) = 0

        [GroupHeader(Main,Surface Below)]
        [GroupToggle(Main)]_SurfaceBelowOn("_SurfaceBelowOn",float) = 0
        [GroupItem(Main)]_SurfaceDepth("_SurfaceDepth",float) = -1
        [GroupItem(Main)]_BelowColor("_BelowColor",color) = (1,1,1,1)

        [GroupHeader(Main,Normal)]
        [GroupItem(Main)][Normal]_NormalMap("_NormalMap",2d) ="bump"{}
        [GroupItem(Main)]_NormalScale("_NormalScale",range(0,5)) = 1

        [GroupHeader(Main,PBRMask)]
        [GroupItem(Main)]_MetallicMaskMap("_MetallicMaskMap(Metallic(R),Smoothness(G),Occlusion(B))",2d) = "white"{}
        // only gui
        [GroupItem(Main)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(Main)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(Main)]_Occlusion("_Occlusion",range(0,1)) = 0.5
        [GroupToggle(Main)]_InvertSmoothnessOn("_InvertSmoothnessOn",int) = 0
        
        [GroupHeader(Surface,mrt options)]
        [GroupItem(Surface,ssr use this)]_MRTSmoothness("_MRTSmoothness",range(0,1)) = 1
        
//------- disable temporary
        // [GroupHeader(Main,PBRMask Channel)]
        // [GroupEnum(Main,R 0 G 1 B 2)]_MetallicChannel("_MetallicChannel",int) = 0
        // [GroupEnum(Main,R 0 G 1 B 2)]_SmoothnessChannel("_SmoothnessChannel",int) = 1
        // [GroupEnum(Main,R 0 G 1 B 2)]_OcclusionChannel("_OcclusionChannel",int) = 2
//================================================= Parallax
        [Group(Parallax)]
        [GroupToggle(Parallax,_PARALLAX)]_ParallaxOn("_ParallaxOn",int) = 0
        [GroupSlider(Parallax,iterate count,int)]_ParallaxIterate("_ParallaxIterate",range(1,10)) = 1
        // [GroupToggle(Parallax,run in vertex shader)]_ParallaxInVSOn("_ParallaxInVSOn",int) = 0
        
        [GroupItem(Parallax)]_ParallaxMap("_ParallaxMap",2d) = "white"{}
        [GroupEnum(Parallax,R 0 G 1 B 2 A 3)]_ParallaxMapChannel("_ParallaxMapChannel",int) = 3
        [GroupSlider(Parallax)]_ParallaxHeight("_ParallaxHeight",range(0.005,0.3)) = 0.01

//================================================= Emission
        [Header(Emission)]
        [GroupToggle(,_EMISSION)]_EmissionOn("_EmissionOn",int) = 0
        [noscaleoffset]_EmissionMap("_EmissionMap(rgb:Color,a:Mask)",2d) = "white"{}
        [hdr]_EmissionColor("_EmissionColor",Color) = (0,0,0,0)

        [Group(World Emission)]
        [GroupToggle(World Emission)]_EmissionHeightOn("_EmissionHeightOn",int) = 0
        [GroupVectorSlider(World Emission,min maxOffset,m100_100 m100_100,,float)]_EmissionHeight("_EmissionHeight",vector)  = (0,0,0,0)
        [GroupItem(World Emission)][hdr]_EmissionHeightColor("_EmissionHeightColor",color)  = (1,1,1,1)
        [GroupToggle(World Emission)]_EmissionHeightColorNormalAttenOn("_EmissionHeightColorNormalAttenOn",int) = 1

        // [Group(WorldScaneLine)]
        // [GroupToggle(WorldScaneLine)]_EmissionScanLineOn("_EmissionScanLineOn",int) = 0
        // [GroupItem(WorldScaneLine)]_EmissionScanLineColor("_EmissionScanLineColor",color) = (1,1,1,1)
        // [GroupItem(WorldScaneLine)]_EmissionScanLineMin("_EmissionScanLineMin",vector) = (0,0,0,0)
        // [GroupItem(WorldScaneLine)]_EmissionScanLineMax("_EmissionScanLineMax",vector) = (100,0,0,0)
        // [GroupItem(WorldScaneLine)]_EmissionScanLineRate("_EmissionScanLineRate",range(0,1)) = 0

//================================================= Shadow
        [GroupHeader(,Shadow)]
        [GroupToggle(,_RECEIVE_SHADOWS_OFF)]_IsReceiveShadowOff("_IsReceiveShadowOff",int) = 0
        [GroupToggle()]_GIApplyMainLightShadow("_GIApplyMainLightShadow",int) = 0

        [GroupHeader(,ScreenShadow)]
        [GroupToggle()]_ScreenShadowOn("_ScreenShadowOn",int) = 0

        [GroupHeader(,_BigShadowOff)]
        [GroupToggle]_BigShadowOff("_BigShadowOff",int) = 0
        

        // [GroupHeader(CloudShadow)]
        // [GroupToggle(,_CLOUD_SHADOW_ON)]_CloudShadowOn("_CloudShadowOn",int) = 0
        // // [GroupVectorSlider(,TilingX TilingZ OffsetX OffsetZ,m0.0001_10)]
        // _CloudShadowTilingOffset("_CloudShadowTilingOffset",vector) = (0.1,0.1,0.1,0.1)

        // [GroupVectorSlider(,Intensity BaseIntensity,m0_10 m0_1)]
        // _CloudShadowIntensityInfo("_CloudShadowIntensityInfo",vector) = (0.5,0.5,0,0)
        // _CloudShadowColor("_CloudShadowColor",color) = (0,0,0,0)
//================================================= Env
        [GroupHeader(,Custom IBL)]
        [GroupToggle(,_IBL_ON)]_IBLOn("_IBLOn",float) = 0
        [NoScaleOffset]_IBLCube("_IBLCube",cube) = ""{}

        [GroupHeader(,IBL Params)]
        _EnvIntensity("_EnvIntensity",float) = 1
        // [GroupToggle]_IBLMaskMainTexA("_IBLMaskMainTexA",float) = 0
        [GroupVectorSlider(_,DirOffset UVBorder, 0_0.5,DirOffset used for Reflection UVBorder used for InteriorMap )]_ReflectDirOffset("_ReflectDirOffset",vector) = (0,0,0,0)
        // [GroupToggle(,_INTERIOR_MAP_ON)]_InteriorMapOn("_InteriorMapOn",int) = 0

        [GroupHeader(,BoxProjection)]
        [GroupToggle(,_REFLECTION_PROBE_BOX_PROJECTION_1)]_BoxProjectionOn("_BoxProjectionOn",int) = 0

        [Header(Custom Light)]
        [GroupToggle()]_CustomLightOn("_CustomLightOn",float) = 0
        [LightInfo]_CustomLightDir("_CustomLightDir",vector) = (0,1,0,0)
        [hdr][LightInfo(Color)]_CustomLightColor("_CustomLightColor",color) = (0,0,0,0)
        [GroupEnum(_,LightColor 0 SpecularColor 1)]_CustomLightColorUsage("_CustomLightColorUsage",int) = 0

        [Header(Fresnel)]
        _FresnelIntensity("_FresnelIntensity",float) = 1

        [Header(PlanarReflection)]
        [GroupToggle(,_PLANAR_REFLECTION_ON)]_PlanarReflectionOn("_PlanarReflectionOn",int) = 0
        [GroupToggle()]_PlanarReflectionReverseU("_PlanarReflectionReverseU",int) = 0
        [GroupToggle()]_PlanarReflectionReverseV("_PlanarReflectionReverseV",int) = 0

        [Group(Lightmap)]
        // [GroupToggle(Lightmap,LIGHTMAP_ON)]_LightmapOn("_LightmapOn",int) = 0
        [GroupItem(Lightmap)][hdr] _LightmapColor("_LightmapColor",color) = (1,1,1,1)
//================================================= Alpha
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
        [GroupToggle(_)]_AlphaPremultiply("_AlphaPremultiply",int) = 0 //_ALPHA_PREMULTIPLY_ON
//================================================= settings
        [Header(Settings)]
        [GroupToggle]_ZWriteMode("_ZWriteMode",int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",int) = 4
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2

        [Header(Color Mask)]
        [GroupEnum(_,RGBA 16 RGB 15 RG 12 GB 6 RB 10 R 8 G 4 B 2 A 1 None 0)]
        _ColorMask("_ColorMask",int) = 15

//=================================================  weather
        [Header(Wind)]
        [GroupToggle(_,_WIND_ON)]_WindOn("_WindOn (need vertex color.r)",float) = 0
        [GroupVectorSlider(branch edge globalOffset flutterOffset,0_0.4 0_0.5 0_0.6 0_0.06)]_WindAnimParam("_WindAnimParam(x:branch,edge,z : global offset,w:flutter offset)",vector) = (1,1,0.1,0.3)
        [GroupVectorSlider(WindVector Intensity,0_1)]_WindDir("_WindDir,dir:(xyz),Intensity:(w)",vector) = (1,0.1,0,0.5)
        _WindSpeed("_WindSpeed",range(0,1)) = 0.3
  
        [Header(Snow)]
        [GroupToggle(_,_SNOW_ON)]_SnowOn("_SnowOn",int) = 0
        [GroupToggle(Snow,,snow show in edge first)]_ApplyEdgeOn("_ApplyEdgeOn",int) = 1
        [GroupItem(Snow)]_SnowIntensity("_SnowIntensity",range(0,1)) = 0
        [GroupToggle(Snow,,mainTex.a as snow atten)] _SnowIntensityUseMainTexA("_SnowIntensityUseMainTexA",int) = 0

        [Header(Fog)]
        [GroupToggle()]_FogOn("_FogOn",int) = 1
        [GroupToggle(_,SIMPLE_FOG,use simple linear depth height fog)]_SimpleFog("_SimpleFog",int) = 0
        [GroupToggle(_,)]_FogNoiseOn("_FogNoiseOn",int) = 0 //_DEPTH_FOG_NOISE_ON
        [GroupToggle(_)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(_)]_HeightFogOn("_HeightFogOn",int) = 1

        [GroupToggle(_,_RAIN_ON)]_RainOn("_RainOn",int) = 0

        [GroupHeader(Rain Ripple)]
        _RippleTex("_RippleTex",2d)=""{}
        [GroupToggle]_RippleOffsetAutoStop("_RippleOffsetAutoStop",int)=0
        _RippleSpeed("_RippleSpeed",float) = 10
        _RippleIntensity("_RippleIntensity",range(0,10)) = 1

        [GroupHeader(Intensity)]
        _RippleBlendNormal("_RippleBlendNormal",range(0,1)) = 1
        _RippleAlbedoIntensity("_RippleAlbedoIntensity",range(0,1)) = 0.1

        [GroupHeader(Rain Env)]
        _RainColor("_RainColor",color) = (.5,.5,.5,1)
        _RainMetallic("_RainMetallic",range(0,1)) = 0.1
        _RainSmoothness("_RainSmoothness",range(0,1)) = 0.1

        [GroupHeader(Rain Atten)]
        _RainIntensity("_RainIntensity",range(0,1)) = 1
        _RainSlopeAtten("_RainSlopeAtten",range(0,1)) = 0.5
        _RainHeight("_RainHeight",float) = 5
        [GroupEnum(,None DetailPbrSmoothness MainTexAlpha,0 1 2)]_RainMaskFrom("_RainMaskFrom",int) = 0

        [GroupHeader(RainReflect)]
        // [GroupToggle]_RainReflectOn("_RainReflectOn",int) = 0
		// _RainCube("_RainCube",cube)=""{}
        _RainReflectDirOffset("_RainReflectDirOffset",vector) = (0,0,0,0)
        _RainReflectIntensity("_RainReflectIntensity",range(0,1))=0.5

        [GroupHeader(Flow)]
        _RainFlowTilingOffset("_RainFlowTilingOffset",vector) = (10,10,10,10)
        _RainFlowIntensity("_RainFlowIntensity",range(0,1)) = .5

//================================================= Details
        [GroupToggle(,_DETAIL_ON)]_DetailOn("_DetailOn",int) = 0
        
        [Group(Details)]
        [GroupItem(Details)]_DetailPBRMaskMap("_DetailPBRMaskMap",2d) = ""{}
        [GroupItem(Details)]_DetailPBRMetallic("_DetailPBRMetallic",range(0,1)) = 1
        [GroupItem(Details)]_DetailPBRSmoothness("_DetailPBRSmoothness",range(0,1)) = 1
        [GroupItem(Details)]_DetailPBROcclusion("_DetailPBROcclusion",range(0,1)) = 1

        [GroupHeader(Details,PlaneMode)]
        [GroupEnum(Details,XZ 0 XY 1 YZ 2)] _DetailWorldPlaneMode("_DetailWorldPlaneMode",int) = 0
        [GroupHeader(Details,Detail UV 3 plane)]
        [GroupToggle(Details)]_DetailWorldPosTriplanar("_DetailWorldPosTriplanar",int) = 0

        [GroupHeader(Details,PBR Mask Override)]
        [GroupItem(Details)]_DetailPbrMaskApplyMetallic("_DetailPbrMaskApplyMetallic",range(0,1)) = 1
        [GroupItem(Details)]_DetailPbrMaskApplySmoothness("_DetailPbrMaskApplySmoothness",range(0,1)) = 1
        [GroupItem(Details)]_DetailPbrMaskApplyOcclusion("_DetailPbrMaskApplyOcclusion",range(0,1)) = 1

//=================================================  storey
        [GroupToggle(_,_STOREY_ON)]_StoreyTilingOn("_StoreyTilingOn",int) = 0
        [GroupItem]_StoreyHeight("_StoreyHeight",float) = 1
        [GroupVectorSlider(_,WindowCountX WindowCountY LightOffPercent LightSwitchPercent,0_10 0_10 0_1 0_1,Window count info,float)] _StoreyWindowInfo("_StoreyWindowInfo",vector) = (5,2,0.5,0.8)
        [GroupItem(,light auto switching speed)]_StoreyLightSwitchSpeed("_StoreyLightSwitchSpeed",float) = 0
        [GroupToggle(_,,no alpha when light on)]_StoreyLightOpaque("_StoreyLightOpaque",int) = 1

        [Group(StoreyLine)]
        [GroupToggle(StoreyLine)]_StoreyLineOn("_StoreyLineOn",int) = 0
        [GroupItem(StoreyLine)][noscaleoffset]_StoreyLineNoiseMap("_StoreyLineNoiseMap",2d) = "bump"{}
        [GroupItem(StoreyLine)][hdr]_StoreyLineColor("_StoreyLineColor",color) = (1,1,1,1)

// ================================================== stencil settings
        [Group(Stencil)]
        [GroupEnum(Stencil,UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 0
        [GroupItem(Stencil)]_Stencil ("Stencil ID", int) = 0
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)]_StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
//================================================= Debug display
        [GroupToggle(_,DEBUG_DISPLAY)]_DebugDisplay("_DebugDisplay",int) = 0
//================================================= lights
        // [Group(AdditionalLights)]
        // [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHTS)]_CalcAdditionalLights("_CalcAdditionalLights",int) = 0
        // [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHT_SHADOWS)]_ReceiveAdditionalLightShadow("_ReceiveAdditionalLightShadow",int) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            name "Forward"
            blend [_SrcMode][_DstMode]
            zwrite[_ZWriteMode]
            ztest[_ZTestMode]
            cull [_CullMode]
            ColorMask[_ColorMask]
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }

            HLSLPROGRAM
            // #pragma prefer_hlslcc gles
            #pragma vertex vert
            #pragma fragment frag

            // off temp 
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:70
            
            // material keywords
            #pragma shader_feature_local _PARALLAX 
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _PLANAR_REFLECTION_ON
            // #define _EMISSION
            // #define _PLANAR_REFLECTION_ON
            #pragma shader_feature_local_fragment _IBL_ON
            // #pragma shader_feature_local_fragment _ALPHA_PREMULTIPLY_ON
            // #pragma shader_feature_local_fragment _HEIGHT_FOG_ON
            // #pragma shader_feature_local_fragment _DEPTH_FOG_ON
            #pragma shader_feature SIMPLE_FOG
            #pragma shader_feature_local_fragment _SNOW_ON
            #pragma shader_feature_local_vertex _WIND_ON
            #pragma shader_feature_local_fragment _RAIN_ON
            #pragma shader_feature_local_fragment _STOREY_ON
            #pragma shader_feature_local_fragment _DETAIL_ON

            // use uniform if
            // #define _CUSTOM_LIGHT_ON
            #define _SURFACE_BELOW_ON
            // #define _EMISSION_HEIGHT_ON
            // #define _INTERIOR_MAP_ON
            // #pragma shader_feature_local_fragment _CUSTOM_LIGHT_ON
            // #pragma shader_feature_local_fragment _SURFACE_BELOW_ON
            // #pragma shader_feature_local_fragment _EMISSION_HEIGHT_ON

            // off temp
            // #pragma shader_feature_local_fragment _INTERIOR_MAP_ON
            
            // urp keywords 
            #pragma shader_feature_local_fragment _ _REFLECTION_PROBE_BOX_PROJECTION_1
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS //_MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS //_ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            // unity keywords
            // #pragma multi_compile_fog
            #define SHADOWS_FULL_MIX // realtime + shadowMask
            //     #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK // mixed light need open shadow, otherwise no shadowMask
            #pragma multi_compile _ LIGHTMAP_ON
            //     #pragma shader_feature_local_fragment DEBUG_DISPLAY // change to shader_feature

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
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_vertex _WIND_ON

            #define SHADOW_PASS 
        //     #define USE_SAMPLER2D
            #define _MainTexChannel 3
            #define _CustomShadowNormalBias 0
            #define _CustomShadowDepthBias 0
            #define USE_BASEMAP
            #include "Lib/PowerLitInput.hlsl"
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

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
            #pragma shader_feature_local_vertex _WIND_ON

            // #define SHADOW_PASS 
        //     #define USE_SAMPLER2D
            #define _MainTexChannel 3
            #define _CustomShadowNormalBias 0
            #define _CustomShadowDepthBias 0
            #define USE_BASEMAP
            #include "Lib/PowerLitInput.hlsl"
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass{
            Name "DepthNormals"
            Tags{"LightMode"="DepthNormals"}

            cull[_CullMode]
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            // #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            #include "Lib/PowerLitInput.hlsl"
            #include "Lib/DepthNormalsPass.hlsl"
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
            // #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma shader_feature_local_fragment _EMISSION

            #define USE_TEXTURE2D
            #define _PbrMask _MetallicMaskMap
            #define sampler_PbrMask sampler_MetallicMaskMap
            #define USE_BASEMAP
            // #define _MainTex _BaseMap 
            // #define _MainTex_ST _BaseMap_ST
            // #define sampler_MainTex sampler_BaseMap
            #include "Lib/PowerLitCore.hlsl"
            #include "../../PowerShaderLib/URPLib/PBR1_MetaPass.hlsl"
            ENDHLSL
        }

        Pass{
            Name "Defered"
            Tags{"LightMode"="UniversalGBuffer"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _PARALLAX 
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _PLANAR_REFLECTION_ON
            // #define _EMISSION
            // #define _PLANAR_REFLECTION_ON
            #pragma shader_feature_local_fragment _IBL_ON
            // #pragma shader_feature_local_fragment _ALPHA_PREMULTIPLY_ON
            // #pragma shader_feature_local_fragment _HEIGHT_FOG_ON
            // #pragma shader_feature_local_fragment _DEPTH_FOG_ON
            #pragma shader_feature SIMPLE_FOG
            #pragma shader_feature_local_fragment _SNOW_ON
            #pragma shader_feature_local_vertex _WIND_ON
            #pragma shader_feature_local_fragment _RAIN_ON
            #pragma shader_feature_local_fragment _STOREY_ON
            #pragma shader_feature_local_fragment _DETAIL_ON

            // use uniform if
            // #define _CUSTOM_LIGHT_ON
            #define _SURFACE_BELOW_ON
            // #define _CLOUD_SHADOW_ON
            // #define _EMISSION_HEIGHT_ON
            // #define _INTERIOR_MAP_ON
            // #pragma shader_feature_local_fragment _CUSTOM_LIGHT_ON
            // #pragma shader_feature_local_fragment _SURFACE_BELOW_ON
            // #pragma shader_feature_local_fragment _EMISSION_HEIGHT_ON

            // off temp
            // #pragma shader_feature_local_fragment _CLOUD_SHADOW_ON
            // #pragma shader_feature_local_fragment _INTERIOR_MAP_ON
            
            // urp keywords 
            #pragma shader_feature_local_fragment _ _REFLECTION_PROBE_BOX_PROJECTION_1
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS //_ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            // unity keywords
            // #pragma multi_compile_fog
            #define SHADOWS_FULL_MIX // realtime + shadowMask
        //     #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING // use _Shadows_ShadowMaskOn
            #pragma multi_compile _ SHADOWS_SHADOWMASK // mixed light need open shadow, otherwise no shadowMask
            #pragma multi_compile _ LIGHTMAP_ON

            
            #pragma multi_compile_instancing
            #include "Lib/PowerLitCore.hlsl"
            #include "Lib/DeferedPass.hlsl"
            ENDHLSL
        }

    }
    CustomEditor "PowerUtilities.PowerLitShaderGUI"
}
