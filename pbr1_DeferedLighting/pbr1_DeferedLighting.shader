Shader "Hidden/URP/pbr1_DeferedLighting"
{
    Properties
    {


        [Group(Fog)]
        [GroupToggle(Fog)]_FogOn("_FogOn",int) = 1
        [GroupToggle(Fog,SIMPLE_FOG,use simple linear depth height fog)]_SimpleFog("_SimpleFog",int) = 0
        [GroupToggle(Fog)]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(Fog)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(Fog)]_HeightFogOn("_HeightFogOn",int) = 1


        // [Group(Alpha)]
        // [GroupHeader(Alpha,BlendMode)]
        // [GroupPresetBlendMode(Alpha,,_SrcMode,_DstMode)]_PresetBlendMode("_PresetBlendMode",int)=0
        // // [GroupEnum(Alpha,UnityEngine.Rendering.BlendMode)]
        // [HideInInspector]_SrcMode("_SrcMode",int) = 1
        // [HideInInspector]_DstMode("_DstMode",int) = 0

        [Group(Settings)]
        [GroupEnum(Settings,UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
		[GroupToggle(Settings)]_ZWriteMode("ZWriteMode",int) = 1
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[GroupEnum(Settings,UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4
    }

    SubShader
    {
        LOD 100
        Tags { "RenderType"="Transparent" "LightMode"="DeferedLighting"}

        //0 dir light
        Pass
        {
			ZWrite off
			// Blend [_SrcMode][_DstMode]
            Blend One srcAlpha, Zero One
            // BlendOp Add, Add
			// BlendOp[_BlendOp]
			Cull off
			ztest[_ZTestMode]
            zclip false
            
			// ColorMask [_ColorMask]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            
            #include "Lib/PBRInput.hlsl"
            #include "Lib/PBRPass.hlsl"
            
            ENDHLSL
        }
        //1 point 
        Pass
        {
			ZWrite off
			// Blend [_SrcMode][_DstMode]
            Blend One one, Zero One
            // BlendOp Add, Add
			// BlendOp[_BlendOp]
			Cull front
			ztest lequal
            // zclip false
            
			// ColorMask [_ColorMask]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            
            #include "Lib/PBRInput.hlsl"
            #include "Lib/PBRPass.hlsl"
            
            ENDHLSL
        }
    }
}
