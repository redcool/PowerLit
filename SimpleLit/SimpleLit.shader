Shader "URP/SimpleLit"
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
        [GroupItem(Main)]_MainTex ("Texture", 2D) = "white" {}
        [GroupItem(Main)]_Color ("_Color", color) = (1,1,1,1)
        [GroupItem(Main)]_NormalMap("_NormalMap",2d)="bump"{}
        [GroupItem(Main)]_NormalScale("_NormalScale",range(0,5)) = 1

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
        [GroupSlider(Shadow)]_CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0
        [GroupSlider(Shadow)]_CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0

        [Group(AdditionalLights)]
        [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHTS_ON)]_CalcAdditionalLights("_CalcAdditionalLights",int) = 0
        [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHT_SHADOWS_ON)]_ReceiveAdditionalLightShadow("_ReceiveAdditionalLightShadow",int) = 1
        // [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHT_SHADOWS_SOFT)]_AdditionalIghtSoftShadow("_AdditionalIghtSoftShadow",int) = 0

        [Group(Emission)]
        [GroupToggle(Emission,_EMISSION)]_EmissionOn("_EmissionOn",int) = 0
        [GroupItem(Emission)]_EmissionMap("_EmissionMap",2d)=""{}
        [GroupItem(Emission)]_EmissionColor("_EmissionColor(w:mask)",color) = (1,1,1,1)
        [GroupMaterialGI(Emission)]_EmissionGI("_EmissionGI",int) = 0

        [Group(Aniso)]
        [GroupToggle(Aniso)]_CalcTangent("_CalcTangent",int) = 0
        [GroupItem(Aniso)]_AnisoRough("_AnisoRough",range(-0.5,0.5)) = 0
        [GroupItem(Aniso)]_AnisoShift("_AnisoShift",range(-1,1)) = 0

        [Group(Charlie)]
        [GroupVectorSlider(Charlie,Min Max,0_1 0_1)]_ClothRange("_ClothRange",vector) =(0,1,0,0)

        // [Group(Thin Film)]
        // [GroupToggle(Thin Film)]_TFOn("_TFOn",int) = 0
        // [GroupItem(Thin Film)]_TFScale("_TFScale",float) = 1
        // [GroupItem(Thin Film)]_TFOffset("_TFOffset",float) = 0
        // [GroupItem(Thin Film)]_TFSaturate("_TFSaturate",range(0,1)) = 1
        // [GroupItem(Thin Film)]_TFBrightness("_TFBrightness",range(0,1)) = 1

        [Group(Fog)]
        [GroupToggle(Fog)]_FogOn("_FogOn",int) = 1
        [GroupToggle(Fog,_DEPTH_FOG_NOISE_ON)]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(Fog)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(Fog)]_HeightFogOn("_HeightFogOn",int) = 1


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

        [Group(Settings)]
        [GroupEnum(Settings,UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
		[GroupToggle(Settings)]_ZWriteMode("ZWriteMode",int) = 1
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[GroupEnum(Settings,UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4

        //===================== actual values
        [VectorValues(_Metallic _Smoothness _Occlusion _NormalScale)]
        _Metallic_Smoothness_Occlusion_NormalScale("_Metallic_Smoothness_Occlusion_NormalScale",vector)=(1,1,1,1)
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

            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ LIGHTMAP_ON

            #pragma shader_feature_fragment _PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE _PBRMODE_GGX
            #pragma shader_feature_fragment _DEPTH_FOG_NOISE_ON
            #pragma shader_feature_fragment _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_fragment ALPHA_TEST
            #pragma shader_feature_fragment _EMISSION

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
            // #include "Lib/SimpleLitMetaPass.hlsl"
            #include "../../PowerShaderLib/URPLib/PBR1_MetaPass.hlsl"

            ENDHLSL
        }
    }
}
