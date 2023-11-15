Shader "URP/FastLit"
{
    /*
    lighting(pbr,charlie,aniso)
    shadow(main light)
    fog
    srp batched 

    instanced
    detail()
    alpha

    */
    Properties
    {
        [GroupHeader(v0.0.5)]
        [Group(Main)]
        [GroupItem(Main)] [MainTexture] _BaseMap ("Texture", 2D) = "white" {}
        [GroupItem(Main)][hdr]_Color ("_Color", color) = (1,1,1,1)
        [GroupItem(Main)]_NormalMap("_NormalMap",2d)="bump"{}
        [GroupItem(Main)]_NormalScale("_NormalScale",range(0,5)) = 1
        [GroupToggle(Main)] _AlbedoMulVertexColor("_AlbedoMulVertexColor",float) = 0
        
        [Group(PBR Mask)]
        [GroupItem(PBR Mask)]_MetallicMaskMap("_PbrMask",2d)="white"{}

        [GroupItem(PBR Mask)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Occlusion("_Occlusion",range(0,1)) = 0

        [Group(LightMode)]   
        [GroupToggle(LightMode)]_SpecularOn("_SpecularOn",int) = 1
        // [Enum(PBR,0,Aniso,1,Charlie,2)]_PbrMode("_PbrMode",int) = 0
        [GroupEnum(LightMode,_PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE _PBRMODE_GGX,true)]_PbrMode("_PbrMode",int) = 0
        
        [Group(Shadow)]
        //[LineHeader(Shadows)]
        [GroupToggle(Shadow,_RECEIVE_SHADOWS_OFF)]_ReceiveShadowOff("_ReceiveShadowOff",int) = 0
        [GroupItem(Shadow)]_MainLightShadowSoftScale("_MainLightShadowSoftScale",range(0,1)) = 0.1

        [GroupHeader(Shadow,custom bias)]
        [GroupSlider(Shadow,,float)]_CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0
        [GroupSlider(Shadow,,float)]_CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0

        [Group(AdditionalLights)]
        [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHTS_ON)]_CalcAdditionalLights("_CalcAdditionalLights",int) = 0
        [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHT_SHADOWS_ON)]_ReceiveAdditionalLightShadow("_ReceiveAdditionalLightShadow",int) = 1
        // [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHT_SHADOWS_SOFT)]_AdditionalIghtSoftShadow("_AdditionalIghtSoftShadow",int) = 0

        [Group(Emission)]
        [GroupToggle(Emission,_EMISSION)]_EmissionOn("_EmissionOn",int) = 0
        [GroupItem(Emission)]_EmissionMap("_EmissionMap(rgb:Color,a:Mask)",2d)=""{}
        [hdr][GroupItem(Emission)]_EmissionColor("_EmissionColor(w:mask)",color) = (1,1,1,1)
        [GroupMaterialGI(Emission)]_EmissionGI("_EmissionGI",int) = 0

        [Group(Aniso)]
        [GroupToggle(Aniso)]_CalcTangent("_CalcTangent",int) = 0
        [GroupItem(Aniso)]_AnisoRough("_AnisoRough",range(-0.5,0.5)) = 0
        [GroupItem(Aniso)]_AnisoShift("_AnisoShift",range(-1,1)) = 0

        [Group(Charlie)]
        [GroupVectorSlider(Charlie,Min Max,0_1 0_1)]_ClothRange("_ClothRange",vector) =(0,1,0,0)

//================================================= Env
        [Group(Env)]
        [GroupHeader(Env,Custom IBL)]
        [GroupToggle(Env,_IBL_ON)]_IBLOn("_IBLOn",float) = 0
        [GroupItem(Env)][NoScaleOffset]_IBLCube("_IBLCube",cube) = ""{}

        [GroupHeader(Env,IBL Params)]
        [GroupItem(Env)]_EnvIntensity("_EnvIntensity",float) = 1
        // [GroupToggle]_IBLMaskMainTexA("_IBLMaskMainTexA",float) = 0
        [GroupVectorSlider(Env,DirOffset UVBorder, 0_0.5,DirOffset used for Reflection UVBorder used for InteriorMap )]_ReflectDirOffset("_ReflectDirOffset",vector) = (0,0,0,0)
        // [GroupToggle(Env,_INTERIOR_MAP_ON)]_InteriorMapOn("_InteriorMapOn",int) = 0

        [GroupHeader(Env,BoxProjection)]
        [GroupToggle(Env,_REFLECTION_PROBE_BOX_PROJECTION)]_BoxProjectionOn("_BoxProjectionOn",int) = 0

        [GroupHeader(Env,Custom Light)]
        [GroupToggle(Env)]_CustomLightOn("_CustomLightOn",float) = 0
        [GroupItem(Env)][LightInfo(Env,direction)]_CustomLightDir("_CustomLightDir",vector) = (0,1,0,0)
        [GroupItem(Env)][hdr][LightInfo(Env,Color)]_CustomLightColor("_CustomLightColor",color) = (0,0,0,0)
        [GroupEnum(Env,LightColor 0 SpecularColor 1)]_CustomLightColorUsage("_CustomLightColorUsage",int) = 0
        [GroupHeader(Env,Fresnel)]
        [GroupItem(Env)]_FresnelIntensity("_FresnelIntensity",float) = 1
        // [Group(Thin Film)]
        // [GroupToggle(Thin Film)]_TFOn("_TFOn",int) = 0
        // [GroupItem(Thin Film)]_TFScale("_TFScale",float) = 1
        // [GroupItem(Thin Film)]_TFOffset("_TFOffset",float) = 0
        // [GroupItem(Thin Film)]_TFSaturate("_TFSaturate",range(0,1)) = 1
        // [GroupItem(Thin Film)]_TFBrightness("_TFBrightness",range(0,1)) = 1
//=================================================  weather
        [Group(Fog)]
        [GroupToggle(Fog)]_FogOn("_FogOn",int) = 1
        [GroupToggle(Fog,_DEPTH_FOG_NOISE_ON)]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(Fog)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(Fog)]_HeightFogOn("_HeightFogOn",int) = 1

        [Group(Wind)]
        [GroupToggle(Wind,_WIND_ON)]_WindOn("_WindOn (need vertex color.r)",float) = 0
        [GroupVectorSlider(Wind,branch edge globalOffset flutterOffset,0_0.4 0_0.5 0_0.6 0_0.06)]_WindAnimParam("_WindAnimParam(x:branch,edge,z : global offset,w:flutter offset)",vector) = (1,1,0.1,0.3)
        [GroupVectorSlider(Wind,WindVector Intensity,0_1)]_WindDir("_WindDir,dir:(xyz),Intensity:(w)",vector) = (1,0.1,0,0.5)
        [GroupItem(Wind)]_WindSpeed("_WindSpeed",range(0,1)) = 0.3
  
        [Group(Snow)]
        [GroupToggle(Snow,_SNOW_ON)]_SnowOn("_SnowOn",int) = 0
        [GroupToggle(Snow)]_ApplyEdgeOn("_ApplyEdgeOn",int) = 1
        [GroupItem(Snow)]_SnowIntensity("_SnowIntensity",range(0,1)) = 0

        [Group(Rain)]
        [GroupToggle(Rain,_RAIN_ON)]_RainOn("_RainOn",int) = 0

        [GroupHeader(Rain,Ripple)]
        [GroupItem(Rain)]_RippleTex("_RippleTex",2d)=""{}
        [GroupToggle(Rain)]_RippleOffsetAutoStop("_RippleOffsetAutoStop",int)=0
        [GroupItem(Rain)]_RippleSpeed("_RippleSpeed",float) = 10
        [GroupItem(Rain)]_RippleIntensity("_RippleIntensity",range(0,10)) = 1

        [GroupHeader(Rain,Intensity)]
        [GroupItem(Rain)]_RippleBlendNormal("_RippleBlendNormal",range(0,1)) = 1
        [GroupItem(Rain)]_RippleAlbedoIntensity("_RippleAlbedoIntensity",range(0,1)) = 0.1

        [GroupHeader(Rain, Env)]
        [GroupItem(Rain)]_RainColor("_RainColor",color) = (.5,.5,.5,1)
        [GroupItem(Rain)]_RainMetallic("_RainMetallic",range(0,1)) = 0.1
        [GroupItem(Rain)]_RainSmoothness("_RainSmoothness",range(0,1)) = 0.1

        [GroupHeader(Rain, Atten)]
        [GroupItem(Rain)]_RainIntensity("_RainIntensity",range(0,1)) = 1
        [GroupItem(Rain)]_RainSlopeAtten("_RainSlopeAtten",range(0,1)) = 0.5
        [GroupItem(Rain)]_RainHeight("_RainHeight",float) = 5
        [GroupEnum(Rain,None DetailPbrSmoothness MainTexAlpha,0 1 2)]_RainMaskFrom("_RainMaskFrom",int) = 0

        [GroupHeader(Rain,Reflect)]
        // [GroupToggle]_RainReflectOn("_RainReflectOn",int) = 0
		// _RainCube("_RainCube",cube)=""{}
        [GroupItem(Rain)]_RainReflectDirOffset("_RainReflectDirOffset",vector) = (0,0,0,0)
        [GroupItem(Rain)]_RainReflectIntensity("_RainReflectIntensity",range(0,1))=0.5

        [GroupHeader(Rain,Flow)]
        [GroupItem(Rain)]_RainFlowTilingOffset("_RainFlowTilingOffset",vector) = (10,10,10,10)
        [GroupItem(Rain)]_RainFlowIntensity("_RainFlowIntensity",range(0,1)) = .5

        // [Group(Lightmap)]
        // [GroupToggle(Lightmap,LIGHTMAP_ON)]_LightmapOn("_LightmapOn",int) = 0
        [Group(Alpha)]
        [GroupHeader(Alpha,BlendMode)]
        [GroupPresetBlendMode(Alpha,,_SrcMode,_DstMode)]_PresetBlendMode("_PresetBlendMode",int)=0
        // [GroupEnum(Alpha,UnityEngine.Rendering.BlendMode)]
        [HideInInspector]_SrcMode("_SrcMode",int) = 1
        [HideInInspector]_DstMode("_DstMode",int) = 0

        [GroupHeader(Alpha,Premultiply)]
        [GroupToggle(Alpha)]_AlphaPremultiply("_AlphaPremultiply",int) = 0

        [GroupHeader(Alpha,AlphaTest)]
        [GroupToggle(Alpha,ALPHA_TEST)]_AlphaTestOn("_AlphaTestOn",int) = 0
        [GroupSlider(Alpha)]_Cutoff("_Cutoff",range(0,1)) = 0.5

        [Group(PlanarReflection)]
        [GroupToggle(PlanarReflection,_PLANAR_REFLECTION_ON)]_PlanarReflectionOn("_PlanarReflectionOn",int) = 0

        [Group(Settings)]
        [GroupEnum(Settings,UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
		[GroupToggle(Settings)]_ZWriteMode("ZWriteMode",int) = 1
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[GroupEnum(Settings,UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4

        //===================== actual values
        // [VectorValues(_Metallic _Smoothness _Occlusion _NormalScale)]
        // _Metallic_Smoothness_Occlusion_NormalScale("_Metallic_Smoothness_Occlusion_NormalScale",vector)=(1,1,1,1)

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			ZWrite[_ZWriteMode]
			Blend [_SrcMode][_DstMode]
			// BlendOp[_BlendOp]
			Cull[_CullMode]
			ztest[_ZTestMode]
			// ColorMask [_ColorMask]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            // #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma shader_feature_fragment _ADDITIONAL_LIGHTS_ON
            #pragma shader_feature_fragment _ _ADDITIONAL_LIGHT_SHADOWS_ON
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS_SOFT

            #define SHADOWS_FULL_MIX
            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ LIGHTMAP_ON

            #pragma shader_feature_fragment _PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE _PBRMODE_GGX
            #pragma shader_feature_fragment _DEPTH_FOG_NOISE_ON
            #pragma shader_feature_fragment _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_fragment ALPHA_TEST
            #pragma shader_feature_fragment _EMISSION
            #pragma shader_feature_fragment _PLANAR_REFLECTION_ON

            #pragma shader_feature_local_fragment _SNOW_ON
            #pragma shader_feature_local_vertex _WIND_ON
            #pragma shader_feature_local_fragment _RAIN_ON

            #pragma shader_feature_local_fragment _IBL_ON
            #pragma shader_feature_local_fragment _REFLECTION_PROBE_BOX_PROJECTION
            

            #include "Lib/PBRInput.hlsl"
            #include "Lib/PBRForwardPass.hlsl"
            
            ENDHLSL
        }

        Pass{
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            #pragma shader_feature_fragment ALPHA_TEST

            #define USE_SAMPLER2D
            #include "Lib/PBRInput.hlsl"
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }

        Pass{
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma shader_feature_fragment ALPHA_TEST
            #pragma shader_feature_local_vertex _WIND_ON

            #define SHADOW_PASS 
            #define USE_SAMPLER2D
            #define _MainTexChannel 3
            #define _CustomShadowNormalBias _CustomShadowNormalBias
            #define _CustomShadowDepthBias _CustomShadowDepthBias
            #include "Lib/PBRInput.hlsl"
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass{
            Name "Meta"
            Tags{"LightMode" = "Meta"}
            Cull Off
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            #pragma shader_feature_fragment ALPHA_TEST
            #pragma shader_feature_local_fragment _EMISSION

            #include "Lib/PBRInput.hlsl"
            // #include "Lib/FastLitMetaPass.hlsl"
            #include "../../PowerShaderLib/URPLib/PBR1_MetaPass.hlsl"

            ENDHLSL
        }
    }
}
