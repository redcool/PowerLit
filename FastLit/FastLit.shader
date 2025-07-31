Shader "URP/FastLit"
{
    Properties
    {
        [GroupHeader(v0.0.5)]
        [Group(Main)]
        [GroupItem(Main)] [MainTexture] _BaseMap ("Texture", 2D) = "white" {}
        [GroupItem(Main)][hdr][gamma]_Color ("_Color", color) = (1,1,1,1)
        [GroupToggle(Main)] _AlbedoMulVertexColor("_AlbedoMulVertexColor",float) = 0
        [GroupItem(Main)]_NormalMap("_NormalMap",2d)="bump"{}
        [GroupItem(Main)]_NormalScale("_NormalScale",range(0,5)) = 1
        
        [Group(PBR Mask)]
        [GroupItem(PBR Mask)]_MetallicMaskMap("_PbrMask",2d)="white"{}

        [GroupItem(PBR Mask)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Occlusion("_Occlusion",range(0,1)) = 0
        
        [GroupHeader(Surface,mrt options)]
        [GroupItem(Surface,ssr use this)]_MRTSmoothness("_MRTSmoothness",range(0,1)) = 1

        [Group(LightMode)]
        [GroupToggle(LightMode)]_SpecularOn("_SpecularOn",int) = 1
        // [Enum(PBR,0,Aniso,1,Charlie,2)]_PbrMode("_PbrMode",int) = 0
        // [GroupEnum(LightMode,_PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE,true)]_PbrMode("_PbrMode",int) = 0
//=================================================  Diffuse
        [Group(Cell Diffuse)]
        [GroupToggle(Cell Diffuse)]_CellDiffuseOn("_CellDiffuseOn",int) = 0
        [GroupVectorSlider(Lighting,Min Max,0_1 0_1)] _DiffuseRange("_DiffuseRange",vector) = (0,0.5,0,0)
//=================================================  Shadow
        [Group(Shadow)]
        //[LineHeader(Shadows)]
        [GroupToggle(Shadow,_RECEIVE_SHADOWS_OFF)]_ReceiveShadowOff("_ReceiveShadowOff",int) = 0
        [GroupItem(Shadow)]_MainLightShadowSoftScale("_MainLightShadowSoftScale",range(0,1)) = 0.1

        [GroupHeader(,_BigShadowOff)]
        [GroupToggle]_BigShadowOff("_BigShadowOff",int) = 0

        [Group(AdditionalLights)]
        //_ADDITIONAL_LIGHTS_ON  
        [GroupToggle(AdditionalLights,)]_CalcAdditionalLights("_CalcAdditionalLights",int) = 0
        // _ADDITIONAL_LIGHT_SHADOWS_ON
        [GroupToggle(AdditionalLights,)]_ReceiveAdditionalLightShadow("_ReceiveAdditionalLightShadow",int) = 1
        // [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHT_SHADOWS_SOFT)]_AdditionalIghtSoftShadow("_AdditionalIghtSoftShadow",int) = 0
        [GroupHeader(,RotateShadow)]
        [GroupToggle(,,shadow caster use matrix _CameraYRot or _MainLightYRot )]_RotateShadow("_RotateShadow",int) = 0
//================================================= Details
        [Group(Details)]
        [GroupToggle(Details,_DETAIL_ON)]_DetailOn("_DetailOn",int) = 0
        [GroupItem(Details)]_DetailPBRMaskMap("_DetailPBRMaskMap",2d) = ""{}
        [GroupItem(Details)]_DetailPBRMetallic("_DetailPBRMetallic",range(0,1)) = 1
        [GroupItem(Details)]_DetailPBRSmoothness("_DetailPBRSmoothness",range(0,1)) = 1
        [GroupItem(Details)]_DetailPBROcclusion("_DetailPBROcclusion",range(0,1)) = 1

        [GroupHeader(Details,PlaneMode)]
        [GroupEnum(Details,XZ 0 XY 1 YZ 2)] _DetailWorldPlaneMode("_DetailWorldPlaneMode",int) = 0
        // [GroupHeader(Details,Detail UV 3 plane)]
        // [GroupToggle(Details)]_DetailWorldPosTriplanar("_DetailWorldPosTriplanar",int) = 0

        [GroupHeader(Details,PBR Mask Override)]
        [GroupItem(Details)]_DetailPbrMaskApplyMetallic("_DetailPbrMaskApplyMetallic",range(0,1)) = 1
        [GroupItem(Details)]_DetailPbrMaskApplySmoothness("_DetailPbrMaskApplySmoothness",range(0,1)) = 1
        [GroupItem(Details)]_DetailPbrMaskApplyOcclusion("_DetailPbrMaskApplyOcclusion",range(0,1)) = 1
//================================================= emission
        [Group(Emission)]
        [GroupToggle(Emission,)]_EmissionOn("_EmissionOn",int) = 0  //_EMISSION
        [GroupItem(Emission)]_EmissionMap("_EmissionMap(rgb:Color,a:Mask)",2d)=""{}
        [hdr][GroupItem(Emission)]_EmissionColor("_EmissionColor(w:mask)",color) = (0,0,0,0)
        [GroupMaterialGI(Emission)]_EmissionGI("_EmissionGI",int) = 0
//=================================================  world emission
        [Group(WorldEmission)]
        [GroupToggle(WorldEmission)]_EmissionHeightOn("_EmissionHeightOn",int) = 0
        [GroupVectorSlider(WorldEmission,min maxOffset,m100_100 m100_100,,float)]_EmissionHeight("_EmissionHeight",vector)  = (0,0,0,0)
        [GroupItem(WorldEmission)][hdr]_EmissionHeightColor("_EmissionHeightColor",color)  = (1,1,1,1)
        [GroupToggle(WorldEmission)]_EmissionHeightColorNormalAttenOn("_EmissionHeightColorNormalAttenOn",int) = 1

//=================================================  storey emission
        [Group(StoreyEmission)]
        [GroupToggle(StoreyEmission,_STOREY_ON)]_StoreyTilingOn("_StoreyTilingOn",int) = 0
        [GroupItem(StoreyEmission)]_StoreyHeight("_StoreyHeight",float) = 1
        [GroupVectorSlider(StoreyEmission,WindowCountX WindowCountY LightOffPercent LightSwitchPercent,0_10 0_10 0_1 0_1,Window count info,float)] _StoreyWindowInfo("_StoreyWindowInfo",vector) = (5,2,0.5,0.8)

        [GroupItem(StoreyEmission,light auto switching speed)]_StoreyLightSwitchSpeed("_StoreyLightSwitchSpeed",float) = 0
        [GroupToggle(StoreyEmission,,no alpha when light on)]_StoreyLightOpaque("_StoreyLightOpaque",int) = 1

        // [Group(StoreyLine)]
        // [GroupToggle(StoreyLine)]_StoreyLineOn("_StoreyLineOn",int) = 0
        // [GroupItem(StoreyLine)][noscaleoffset]_StoreyLineNoiseMap("_StoreyLineNoiseMap",2d) = "bump"{}
        // [GroupItem(StoreyLine)][hdr]_StoreyLineColor("_StoreyLineColor",color) = (1,1,1,1)        
//================================================= Speculars     
        [Group(Aniso)]
        [GroupToggle(Aniso)]_CalcTangent("_CalcTangent",int) = 0
        [GroupItem(Aniso)]_AnisoRough("_AnisoRough",range(-0.5,0.5)) = 0
        [GroupItem(Aniso)]_AnisoShift("_AnisoShift",range(-1,1)) = 0

        [Group(Charlie)]
        [GroupVectorSlider(Charlie,Min Max,0_1 0_1)]_ClothRange("_ClothRange",vector) =(0,1,0,0)

//================================================= Env
        [Group(Env)]
        [GroupHeader(Env,Custom Light)]
        [GroupToggle(Env)]_CustomLightOn("_CustomLightOn",float) = 0
        [GroupItem(Env)][LightInfo(Env,direction)]_CustomLightDir("_CustomLightDir",vector) = (0,1,0,0)
        [GroupItem(Env)][hdr][LightInfo(Env,Color)]_CustomLightColor("_CustomLightColor",color) = (0,0,0,0)
        [GroupEnum(Env,LightColor 0 SpecularColor 1)]_CustomLightColorUsage("_CustomLightColorUsage",int) = 0

        [GroupHeader(Env,Custom IBL)]
        [GroupToggle(Env,_IBL_ON)]_IBLOn("_IBLOn",float) = 0
        [GroupItem(Env)][NoScaleOffset]_IBLCube("_IBLCube",cube) = ""{}

        [GroupHeader(Env,IBL Params)]
        [GroupItem(Env)]_EnvIntensity("_EnvIntensity",float) = 1
        // [GroupToggle]_IBLMaskMainTexA("_IBLMaskMainTexA",float) = 0
        [GroupVectorSlider(Env,DirOffset UVBorder, 0_0.5,DirOffset used for Reflection UVBorder used for InteriorMap )]_ReflectDirOffset("_ReflectDirOffset",vector) = (0,0,0,0)
        // [GroupToggle(Env,_INTERIOR_MAP_ON)]_InteriorMapOn("_InteriorMapOn",int) = 0

        [GroupHeader(Env,BoxProjection)]
        //_REFLECTION_PROBE_BOX_PROJECTION_1
        [GroupToggle(Env,)]_BoxProjectionOn("_BoxProjectionOn",int) = 0

        [GroupHeader(Env,Fresnel)]
        [GroupItem(Env)]_FresnelIntensity("_FresnelIntensity",float) = 1
        
        [Group(Lightmap)]
        // [GroupToggle(Lightmap,LIGHTMAP_ON)]_LightmapOn("_LightmapOn",int) = 0
        [GroupItem(Lightmap)][hdr] _LightmapColor("_LightmapColor",color) = (1,1,1,1)
        // [Group(Thin Film)]
        // [GroupToggle(Thin Film)]_TFOn("_TFOn",int) = 0
        // [GroupItem(Thin Film)]_TFScale("_TFScale",float) = 1
        // [GroupItem(Thin Film)]_TFOffset("_TFOffset",float) = 0
        // [GroupItem(Thin Film)]_TFSaturate("_TFSaturate",range(0,1)) = 1
        // [GroupItem(Thin Film)]_TFBrightness("_TFBrightness",range(0,1)) = 1
//=================================================  weather
        [Group(Fog)]
        [GroupToggle(Fog)]_FogOn("_FogOn",int) = 1
        // [GroupToggle(Fog,SIMPLE_FOG,use simple linear depth height fog)]_SimpleFog("_SimpleFog",int) = 0
        [GroupToggle(Fog,,use PowerLitFogControl FogNoise control noise )]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(Fog)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(Fog)]_HeightFogOn("_HeightFogOn",int) = 1
        [GroupItem(Fog,SphereFogDatas index)]_SphereFogId("_SphereFogId",int) = 0
//================================================= Wind  
        [Group(Wind)]
        [GroupToggle(Wind,)]_WindOn("_WindOn (need vertex color.r)",float) = 0  // _WIND_ON
        [GroupVectorSlider(Wind,branch edge globalOffset flutterOffset,0_0.4 0_0.5 0_0.6 0_0.06)]_WindAnimParam("_WindAnimParam(x:branch,edge,z : global offset,w:flutter offset)",vector) = (1,1,0.1,0.3)
        [GroupVectorSlider(Wind,WindVector Intensity,0_1)]_WindDir("_WindDir,dir:(xyz),Intensity:(w)",vector) = (1,0.1,0,0.5)
        [GroupItem(Wind)]_WindSpeed("_WindSpeed",range(0,1)) = 0.3
//================================================= Snow  
        [Group(Snow)]
        [GroupToggle(Snow,_SNOW_ON)]_SnowOn("_SnowOn",int) = 0
        [GroupToggle(Snow,,snow show in edge first)]_ApplyEdgeOn("_ApplyEdgeOn",int) = 1
        [GroupItem(Snow)]_SnowIntensity("_SnowIntensity",range(0,1)) = 0
        [GroupToggle(Snow,,mainTex.a as snow atten)] _SnowIntensityUseMainTexA("_SnowIntensityUseMainTexA",int) = 0

        [GroupHeader(Snow,SnowNoise)]
        [GroupVectorSlider(Snow,NoiseTilingX NoiseTilingY,0_10 0_10,,float)]_SnowNoiseTiling("_SnowNoiseTiling",vector) = (1,1,0,0)
        [GroupVectorSlider(Snow,weightR weightG weightB weightA,0_10 0_10 0_10 0_10,,float)]_SnowNoiseWeights("_SnowNoiseWeights",vector) = (1,.1,.1,1)
        [GroupToggle(Snow,,flatten normal where no snow)]_SnowNormalMask("_SnowNormalMask",float) = 0
        
//================================================= Rain
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

//================================================= Alpha
        [Group(Alpha)]
        [GroupHeader(Alpha,AlphaTest)]
        [GroupToggle(Alpha,ALPHA_TEST)]_ClipOn("_AlphaTestOn",int) = 0
        [GroupSlider(Alpha)]_Cutoff("_Cutoff",range(0,1)) = 0.5
        
        [GroupHeader(Alpha,Premultiply)]
        [GroupToggle(Alpha)]_AlphaPremultiply("_AlphaPremultiply",int) = 0

        [GroupHeader(Alpha,BlendMode)]
        // [GroupPresetBlendMode(Alpha,,_SrcMode,_DstMode)]_PresetBlendMode("_PresetBlendMode",int)=0 // PowerShaderInspector,will show _PresetBlendMode
        // [GroupEnum(Alpha,UnityEngine.Rendering.BlendMode)]
        [HideInInspector]_SrcMode("_SrcMode",int) = 1
        [HideInInspector]_DstMode("_DstMode",int) = 0

//================================================= PlanarReflection
        [Group(PlanarReflection)]
        [GroupToggle(PlanarReflection,_PLANAR_REFLECTION_ON)]_PlanarReflectionOn("_PlanarReflectionOn",int) = 0
        [GroupToggle(PlanarReflection)]_PlanarReflectionReverseU("_PlanarReflectionReverseU",int) = 0
        [GroupToggle(PlanarReflection)]_PlanarReflectionReverseV("_PlanarReflectionReverseV",int) = 0
//================================================= Settings
        [Group(Settings)]
		[GroupToggle(Settings)]_ZWriteMode("ZWriteMode",int) = 1
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[GroupEnum(Settings,UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4
        [GroupEnum(Settings,UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
        [Header(Color Mask)]
        [GroupEnum(_,RGBA 16 RGB 15 RG 12 GB 6 RB 10 R 8 G 4 B 2 A 1 None 0)] _ColorMask("_ColorMask",int) = 15
// ================================================== stencil settings
        [Group(Stencil)]
        [GroupEnum(Stencil,UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Float) = 0
        [GroupStencil(Stencil)] _Stencil ("Stencil ID", int) = 0
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
        [GroupHeader(Stencil,)]
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)] _StencilFailOp ("Stencil Fail Operation", Float) = 0
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)] _StencilZFailOp ("Stencil zfail Operation", Float) = 0
        [GroupItem(Stencil)] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [GroupItem(Stencil)] _StencilReadMask ("Stencil Read Mask", Float) = 255
//================================================= matcap        
        [Group(MatCap)]
        // [GroupItem(MatCap,specTerm MIN_VERSION use )] _MatCap("_MatCap",2d)=""{}
        [GroupItem(MatCap)] _MatCapScale("_MatCapScale",float)= 1
//================================================= Parallax
        [Group(Parallax)]
        [GroupToggle(Parallax)]_ParallaxOn("_ParallaxOn",int) = 0 //_PARALLAX
        // [GroupSlider(Parallax,iterate count,int)]_ParallaxIterate("_ParallaxIterate",range(1,10)) = 1
        // [GroupToggle(Parallax,run in vertex shader)]_ParallaxInVSOn("_ParallaxInVSOn",int) = 0
        
        [GroupItem(Parallax)]_ParallaxMap("_ParallaxMap",2d) = "white"{}
        [GroupEnum(Parallax,R 0 G 1 B 2 A 3)]_ParallaxMapChannel("_ParallaxMapChannel",int) = 3
        [GroupSlider(Parallax)]_ParallaxHeight("_ParallaxHeight",range(0.005,0.3)) = 0.01

        [Group(Curved)]
        [GroupSlider(Curved,x curve intensity,float)] _CurvedSidewayScale("_CurvedSidewayScale",range(-0.01,0.01)) = 0
        [GroupSlider(Curved,y curve intensity,float)] _CurvedBackwardScale("_CurvedBackwardScale",range(-0.01,0.01)) = 0
//================================================= ShadowCaster
        [Group(ShadowCaster)]
        // [GroupEnum(ShadowCaster,UnityEngine.Rendering.CullMode)]_ShadowCasterCullMode("_ShadowCasterCullMode",int) = 2

        [GroupHeader(ShadowCaster,custom bias)]
        [GroupSlider(ShadowCaster,,float)]_CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0
        [GroupSlider(ShadowCaster,,float)]_CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0        
    }

    SubShader
    {
        /**
        fullfeature
        */
        Tags { "RenderType"="Opaque" }
        LOD 600

        Pass
        {
		    name "FastLitForward"
			ZWrite[_ZWriteMode]
			Blend [_SrcMode][_DstMode]
			// BlendOp[_BlendOp]
			Cull[_CullMode]
			ztest[_ZTestMode]
			ColorMask [_ColorMask]

            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                Fail [_StencilFailOp]
                ZFail [_StencilZFailOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            // #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS// _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _SHADOWS_SOFT
            #define _ADDITIONAL_LIGHTS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHTS_ON
            #define _ADDITIONAL_LIGHT_SHADOWS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHT_SHADOWS_ON
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS_SOFT
            
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ LIGHTMAP_ON

            // only use pbr
            #define _PBRMODE_PBR
            // #pragma shader_feature_fragment _PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE //_PBRMODE_GGX
            
            // #pragma shader_feature SIMPLE_FOG
            #define _PARALLAX // #pragma shader_feature_local _PARALLAX 
            #pragma shader_feature_fragment _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_fragment ALPHA_TEST
            #define _EMISSION//#pragma shader_feature_fragment _EMISSION
            #pragma shader_feature_fragment _PLANAR_REFLECTION_ON

            #pragma shader_feature_local_fragment _SNOW_ON
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON
            #pragma shader_feature_local_fragment _RAIN_ON

            #pragma shader_feature_local_fragment _IBL_ON
            #pragma shader_feature_local _STOREY_ON
            #pragma shader_feature_local _DETAIL_ON


            #define _REFLECTION_PROBE_BOX_PROJECTION_1 //#pragma shader_feature_local_fragment _REFLECTION_PROBE_BOX_PROJECTION_1

            // #pragma multi_compile _ MIN_VERSION
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            
            #define SHADOWS_FULL_MIX
            #define _DEPTH_FOG_NOISE_ON
            // #define CALC_WORLD_NOISE_2_LAYERS
            #define OUTPUT_MOTION
            #define OUTPUT_WORLD_POS
            #define OUTPUT_NORMAL
            
            
            #include "Lib/PBRInput.hlsl"
            #if defined(MIN_VERSION)
            // #include "Lib/PBRInputMin.hlsl"
            #include "Lib/PBRForwardPassMin.hlsl"
            #else
            #include "Lib/PBRForwardPass.hlsl"
            #endif

            ENDHLSL
        }
        
        Pass{
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest LEqual
            Cull[_CullMode]
            // ColorMask 0
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            #pragma shader_feature_fragment ALPHA_TEST
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON

            #define USE_SAMPLER2D
            #include "Lib/PBRInput.hlsl"

            #define _CURVED_WORLD
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }

        Pass{
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            cull [_CullMode]
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }            
            HLSLPROGRAM
            #pragma vertex vertShadow
            #pragma fragment frag

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma shader_feature_fragment ALPHA_TEST
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON

            #define SHADOW_PASS 
            #define USE_SAMPLER2D
            #define _MainTexChannel 3
            #define _CustomShadowNormalBias _CustomShadowNormalBias
            #define _CustomShadowDepthBias _CustomShadowDepthBias
            #include "Lib/PBRInput.hlsl"

            #define _CURVED_WORLD
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            // rotate by Mainlight
            float4x4 _MainLightYRot;
            // #define _MainLightYRot _CameraYRot

            shadow_v2f vertShadow(shadow_appdata input){
                input.vertex.xyz = _RotateShadow ? mul(_MainLightYRot,input.vertex).xyz : input.vertex.xyz;

                return vert(input);
            }

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
            // #pragma shader_feature_local_fragment _EMISSION
            #define _EMISSION

            #include "Lib/PBRInput.hlsl"
            // #include "Lib/FastLitMetaPass.hlsl"
            #include "../../PowerShaderLib/URPLib/PBR1_MetaPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Defered"
            Tags{"LightMode"="UniversalGBuffer"}
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
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS// _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _SHADOWS_SOFT
            #define _ADDITIONAL_LIGHTS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHTS_ON
            #define _ADDITIONAL_LIGHT_SHADOWS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHT_SHADOWS_ON
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS_SOFT
            
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ LIGHTMAP_ON

            // only use pbr
            #define _PBRMODE_PBR
            // #pragma shader_feature_fragment _PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE //_PBRMODE_GGX
            
            // #pragma shader_feature SIMPLE_FOG
            #define _PARALLAX // #pragma shader_feature_local _PARALLAX 
            #pragma shader_feature_fragment _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_fragment ALPHA_TEST
            #define _EMISSION//#pragma shader_feature_fragment _EMISSION
            #pragma shader_feature_fragment _PLANAR_REFLECTION_ON

            #pragma shader_feature_local_fragment _SNOW_ON
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON
            #pragma shader_feature_local_fragment _RAIN_ON

            #pragma shader_feature_local_fragment _IBL_ON
            #pragma shader_feature_local _STOREY_ON
            #pragma shader_feature_local _DETAIL_ON
            #define _REFLECTION_PROBE_BOX_PROJECTION_1 //#pragma shader_feature_local_fragment _REFLECTION_PROBE_BOX_PROJECTION_1

            // #pragma multi_compile _ MIN_VERSION
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            
            #define SHADOWS_FULL_MIX
            #define _DEPTH_FOG_NOISE_ON
            
            #define OUTPUT_MOTION
            #define OUTPUT_WORLD_POS
            #define OUTPUT_NORMAL
                        
            #include "Lib/PBRInput.hlsl"
            // #if defined(MIN_VERSION)
            // #include "Lib/PBRForwardPassMin.hlsl"
            // #else
            #include "Lib/DeferedPass.hlsl"
            // #endif

            ENDHLSL
        }
    }

    SubShader //lod 300
    {
        /**
            turn off:
            _RAIN
            _PARALLAX
        */
        Tags { "RenderType"="Opaque" }
        LOD 300

        Pass
        {
		    name "FastLitForward 300"
			ZWrite[_ZWriteMode]
			Blend [_SrcMode][_DstMode]
			// BlendOp[_BlendOp]
			Cull[_CullMode]
			ztest[_ZTestMode]
			ColorMask [_ColorMask]
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            // #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS// _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _SHADOWS_SOFT
            #define _ADDITIONAL_LIGHTS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHTS_ON
            #define _ADDITIONAL_LIGHT_SHADOWS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHT_SHADOWS_ON
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS_SOFT
            
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ LIGHTMAP_ON

            // only use pbr
            // comments this,will use matcap
            #define _PBRMODE_PBR
            // #pragma shader_feature_fragment _PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE //_PBRMODE_GGX
            
            // #pragma shader_feature SIMPLE_FOG
            // #define _PARALLAX // #pragma shader_feature_local _PARALLAX 
            #pragma shader_feature_fragment _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_fragment ALPHA_TEST
            #define _EMISSION//#pragma shader_feature_fragment _EMISSION
            #pragma shader_feature_fragment _PLANAR_REFLECTION_ON

            #pragma shader_feature_local_fragment _SNOW_ON
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON
            // #pragma shader_feature_local_fragment _RAIN_ON

            #pragma shader_feature_local_fragment _IBL_ON
            #pragma shader_feature_local _STOREY_ON
            #pragma shader_feature_local _DETAIL_ON
            #define _REFLECTION_PROBE_BOX_PROJECTION_1 //#pragma shader_feature_local_fragment _REFLECTION_PROBE_BOX_PROJECTION_1

            // #pragma multi_compile _ MIN_VERSION
            // #define MIN_VERSION
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            
            #define SHADOWS_FULL_MIX
            // #define _DEPTH_FOG_NOISE_ON
            // #define CALC_WORLD_NOISE_2_LAYERS
            #define OUTPUT_MOTION
            #define OUTPUT_WORLD_POS
            #define OUTPUT_NORMAL
                        
            
            #include "Lib/PBRInput.hlsl"
            #if defined(MIN_VERSION)
            // #include "Lib/PBRInputMin.hlsl"
            #include "Lib/PBRForwardPassMin.hlsl"
            #else
            #include "Lib/PBRForwardPass.hlsl"
            #endif

            ENDHLSL
        }
        
        Pass{
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest LEqual
            Cull[_CullMode]
            // ColorMask 0
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            #pragma shader_feature_fragment ALPHA_TEST

            #define USE_SAMPLER2D
            #include "Lib/PBRInput.hlsl"

            #define _CURVED_WORLD
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }

        Pass{
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_CullMode]
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma shader_feature_fragment ALPHA_TEST
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON

            #define SHADOW_PASS 
            #define USE_SAMPLER2D
            #define _MainTexChannel 3
            #define _CustomShadowNormalBias _CustomShadowNormalBias
            #define _CustomShadowDepthBias _CustomShadowDepthBias
            #include "Lib/PBRInput.hlsl"

            #define _CURVED_WORLD
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
            // #pragma shader_feature_local_fragment _EMISSION
            #define _EMISSION

            #include "Lib/PBRInput.hlsl"
            // #include "Lib/FastLitMetaPass.hlsl"
            #include "../../PowerShaderLib/URPLib/PBR1_MetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Defered"
            Tags{"LightMode"="UniversalGBuffer"}
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
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS// _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _SHADOWS_SOFT
            #define _ADDITIONAL_LIGHTS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHTS_ON
            #define _ADDITIONAL_LIGHT_SHADOWS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHT_SHADOWS_ON
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS_SOFT
            
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ LIGHTMAP_ON

            // only use pbr
            #define _PBRMODE_PBR
            // #pragma shader_feature_fragment _PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE //_PBRMODE_GGX
            
            // #pragma shader_feature SIMPLE_FOG
            #define _PARALLAX // #pragma shader_feature_local _PARALLAX 
            #pragma shader_feature_fragment _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_fragment ALPHA_TEST
            #define _EMISSION//#pragma shader_feature_fragment _EMISSION
            #pragma shader_feature_fragment _PLANAR_REFLECTION_ON

            #pragma shader_feature_local_fragment _SNOW_ON
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON
            #pragma shader_feature_local_fragment _RAIN_ON

            #pragma shader_feature_local_fragment _IBL_ON
            #pragma shader_feature_local _STOREY_ON
            #pragma shader_feature_local _DETAIL_ON
            #define _REFLECTION_PROBE_BOX_PROJECTION_1 //#pragma shader_feature_local_fragment _REFLECTION_PROBE_BOX_PROJECTION_1

            // #pragma multi_compile _ MIN_VERSION
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            
            #define SHADOWS_FULL_MIX
            #define _DEPTH_FOG_NOISE_ON
            
            #include "Lib/PBRInput.hlsl"
            // #if defined(MIN_VERSION)
            // #include "Lib/PBRForwardPassMin.hlsl"
            // #else
            #include "Lib/DeferedPass.hlsl"
            // #endif

            ENDHLSL
        }
    }
    
    SubShader // MIN_VERSION
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
		    name "FastLitForward"
			ZWrite[_ZWriteMode]
			Blend [_SrcMode][_DstMode]
			// BlendOp[_BlendOp]
			Cull[_CullMode]
			ztest[_ZTestMode]
			ColorMask [_ColorMask]
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            // #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS// _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _SHADOWS_SOFT
            #define _ADDITIONAL_LIGHTS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHTS_ON
            #define _ADDITIONAL_LIGHT_SHADOWS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHT_SHADOWS_ON
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS_SOFT
            
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ LIGHTMAP_ON

            // only use pbr
            // comments this,will use matcap
            #define _PBRMODE_PBR
            // #pragma shader_feature_fragment _PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE //_PBRMODE_GGX
            
            // #pragma shader_feature SIMPLE_FOG
            #pragma shader_feature_fragment _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_fragment ALPHA_TEST
            #define _EMISSION//#pragma shader_feature_fragment _EMISSION
            #pragma shader_feature_fragment _PLANAR_REFLECTION_ON

            #pragma shader_feature_local_fragment _SNOW_ON
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON
            #pragma shader_feature_local_fragment _RAIN_ON

            #pragma shader_feature_local_fragment _IBL_ON
            #pragma shader_feature_local _STOREY_ON
            #pragma shader_feature_local _DETAIL_ON
            #define _REFLECTION_PROBE_BOX_PROJECTION_1 //#pragma shader_feature_local_fragment _REFLECTION_PROBE_BOX_PROJECTION_1

            // #pragma multi_compile _ MIN_VERSION
            #define MIN_VERSION
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            
            #define SHADOWS_FULL_MIX
            // #define _DEPTH_FOG_NOISE_ON
            // // #define CALC_WORLD_NOISE_2_LAYERS
            // #define OUTPUT_MOTION
            // #define OUTPUT_WORLD_POS
            // #define OUTPUT_NORMAL
            

            #include "Lib/PBRInput.hlsl"
            #if defined(MIN_VERSION)
            // #include "Lib/PBRInputMin.hlsl"
            #include "Lib/PBRForwardPassMin.hlsl"
            #else
            #include "Lib/PBRForwardPass.hlsl"
            #endif

            ENDHLSL
        }
        
        Pass{
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ZTest LEqual
            Cull[_CullMode]
            // ColorMask 0
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            #pragma shader_feature_fragment ALPHA_TEST

            #define USE_SAMPLER2D
            #include "Lib/PBRInput.hlsl"

            #define _CURVED_WORLD
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }

        Pass{
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_CullMode]
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                // ReadMask [_StencilReadMask]
                // WriteMask [_StencilWriteMask]
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma shader_feature_fragment ALPHA_TEST
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON

            #define SHADOW_PASS 
            #define USE_SAMPLER2D
            #define _MainTexChannel 3
            #define _CustomShadowNormalBias _CustomShadowNormalBias
            #define _CustomShadowDepthBias _CustomShadowDepthBias
            #include "Lib/PBRInput.hlsl"

            #define _CURVED_WORLD
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
            #define _EMISSION
            // #pragma shader_feature_fragment _EMISSION

            #include "Lib/PBRInput.hlsl"
            // #include "Lib/FastLitMetaPass.hlsl"
            #include "../../PowerShaderLib/URPLib/PBR1_MetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Defered"
            Tags{"LightMode"="UniversalGBuffer"}
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
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS// _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _SHADOWS_SOFT
            #define _ADDITIONAL_LIGHTS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHTS_ON
            #define _ADDITIONAL_LIGHT_SHADOWS_ON // #pragma shader_feature_fragment _ADDITIONAL_LIGHT_SHADOWS_ON
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS_SOFT
            
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ LIGHTMAP_ON

            // only use pbr
            #define _PBRMODE_PBR
            // #pragma shader_feature_fragment _PBRMODE_PBR _PBRMODE_ANISO _PBRMODE_CHARLIE //_PBRMODE_GGX
            
            // #pragma shader_feature SIMPLE_FOG
            #define _PARALLAX // #pragma shader_feature_local _PARALLAX 
            #pragma shader_feature_fragment _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_fragment ALPHA_TEST
            #define _EMISSION//#pragma shader_feature_fragment _EMISSION
            #pragma shader_feature_fragment _PLANAR_REFLECTION_ON

            #pragma shader_feature_local_fragment _SNOW_ON
            #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON
            #pragma shader_feature_local_fragment _RAIN_ON

            #pragma shader_feature_local_fragment _IBL_ON
            #pragma shader_feature_local _STOREY_ON
            #pragma shader_feature_local _DETAIL_ON
            #define _REFLECTION_PROBE_BOX_PROJECTION_1 //#pragma shader_feature_local_fragment _REFLECTION_PROBE_BOX_PROJECTION_1

            // #pragma multi_compile _ MIN_VERSION
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            
            #define SHADOWS_FULL_MIX
            #define _DEPTH_FOG_NOISE_ON
            
            
            #include "Lib/PBRInput.hlsl"
            // #if defined(MIN_VERSION)
            // #include "Lib/PBRForwardPassMin.hlsl"
            // #else
            #include "Lib/DeferedPass.hlsl"
            // #endif

            ENDHLSL
        }        
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "PowerUtilities.PowerShaderInspector"
}
