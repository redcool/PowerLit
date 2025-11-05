Shader "URP/BakedPbrLit_Terrain"
{
    Properties
    {
        [GroupHeader(V0.0.2)]
        [Group(Base)]
        [GroupItem(Base,underground color)] _BaseMap ("_BaseMap", 2D) = "black" {}
        [GroupItem(Base)] _BaseColor ("_BaseColor", color) = (1,1,1,1)
        [GroupToggle(Base,,baseColor multi controlMap remain weight )] _ControlMapRemainWeightOn("_ControlMapRemainWeightOn",float) = 1

        [Group(Splat)]
        [GroupItem(Splat)] _Splat0 ("Splat 1", 2D) = "black" {}
        [GroupItem(Splat)] _SplatColor0 ("_SplatColor 1", color) = (1,1,1,1)
        
        [GroupItem(Splat)] _Splat1 ("Splat 2", 2D) = "black" {}
        [GroupItem(Splat)] _SplatColor1 ("_SplatColor 2", color) = (1,1,1,1)
        
        [GroupItem(Splat)] _Splat2 ("Splat 3", 2D) = "black" {}
        [GroupItem(Splat)] _SplatColor2 ("_SplatColor 3", color) = (1,1,1,1)
        
        [GroupItem(Splat)] _Splat3 ("Splat 4", 2D) = "black" {}
        [GroupItem(Splat)] _SplatColor3 ("_SplatColor 4", color) = (1,1,1,1)

        [GroupItem(Splat,blend splat textures with channels(xyzw))] _Control ("Control Map( no sRGB)", 2D) = "white" {}

        [GroupToggle(Splat,,adjust splat map blend edge)] _SplatEdgeRangeOn("_SplatEdgeRangeOn",float) = 0

        [MaterialDisableGroup(_SplatEdgeRangeOn)]
        [GroupVectorSlider(Splat,edgeMin edgeMax,0_1 0_1,adjust splat map blend edge )]
        _SplatEdgeRange("_SplatEdgeRange",vector) = (0,1,0,0)

        [GroupVectorSlider(Splat,splat0 splat1 splat2 splat3,0_1 0_1 0_1 0_1,splat map blend weights)]
        _SplatBlendWeights("_SplatBlendWeights",vector) = (1,1,1,1)
// ================================================== pbrMask        
//         [Group(PBR Mask)]
//         [GroupItem(PBR Mask)]_PbrMask("_PbrMask",2d)="white"{}

//         [GroupItem(PBR Mask)]_Metallic("_Metallic",range(0,1)) = 0.5
//         [GroupItem(PBR Mask)]_Smoothness("_Smoothness",range(0,1)) = 0.5
//         [GroupItem(PBR Mask)]_Occlusion("_Occlusion",range(0,1)) = 0

// //================================================= Normal
//         [Group(Normal)]
//         [GroupToggle(Normal, NORMAL_MAP_ON,normalMap in tangent space)]_NormalMapOn("_NormalMapOn",int) = 0
//         [GroupItem(Normal)]_NormalMap("_NormalMap",2d)="bump"{}
        
//         [GroupItem(Normal)]_NormalScale("_NormalScale",range(0,5)) = 1        
//         [GroupToggle(Normal, ,output flat normal force)]_NormalUnifiedOn("_NormalUnifiedOn",int) = 0
//================================================= emission
        // [Group(Emission)]
        // [GroupToggle(Emission,_EMISSION)]_EmissionOn("_EmissionOn",int) = 0  //_EMISSION
        // [GroupItem(Emission)]_EmissionMap("_EmissionMap(rgb:Color,a:Mask)",2d)=""{}
        // [hdr][GroupItem(Emission)]_EmissionColor("_EmissionColor(w:mask)",color) = (0,0,0,0)
        // [GroupMaterialGI(Emission)]_EmissionGI("_EmissionGI",int) = 0
//================================================= Env
        [Group(Env)]
        [GroupHeader(Env,Custom IBL)]
        [GroupToggle(Env,_IBL_ON)]_IBLOn("_IBLOn",float) = 0
        [GroupItem(Env)][NoScaleOffset]_IBLCube("_IBLCube",cube) = ""{}
        
        [GroupHeader(Env,IBL Params)]
        [GroupItem(Env,ibl color tint)]_EnvIntensity("_EnvIntensity",color) = (1,1,1,1)
        [GroupItem(Env)]_FresnelIntensity("_FresnelIntensity",float) = 1

        [GroupHeader(Env,GI Diffuse Params)]
        [GroupItem(Env,gi diffuse color tint)][hdr]_GIDiffuseColor("_GIDiffuseColor",color) = (0,0,0,1)
// ================================================== Main Light 
        [Group(Light)]
        [GroupHeader(Light,Main Light)]
        [GroupToggle(Light,,use lit or unlit)]_MainLightOn("_MainLightOn",float) = 0

        [GroupHeader(Light,MainLight Shadow)]
        [GroupToggle(Light,_RECEIVE_SHADOWS_OFF)]_ReceiveShadowOff("_ReceiveShadowOff",int) = 0
        [GroupItem(Light)]_MainLightShadowSoftScale("_MainLightShadowSoftScale",range(0,1)) = 0.1

        [GroupHeader(Light,BigShadow)]
        [GroupToggle(Light)]_BigShadowOff("_BigShadowOff",int) = 0
//================================================= ShadowCaster
        [Group(ShadowCaster)]
        // [GroupEnum(ShadowCaster,UnityEngine.Rendering.CullMode)]_ShadowCasterCullMode("_ShadowCasterCullMode",int) = 2
        [GroupHeader(ShadowCaster,custom bias)]
        [GroupSlider(ShadowCaster,,float)]_CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0
        [GroupSlider(ShadowCaster,,float)]_CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0              
// ================================================== Fog
        [Group(Fog)]
        [GroupToggle(Fog)]_FogOn("_FogOn",int) = 1
        // [GroupToggle(Fog,SIMPLE_FOG,use simple linear depth height fog)]_SimpleFog("_SimpleFog",int) = 0
        [GroupToggle(Fog)]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(Fog)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(Fog)]_HeightFogOn("_HeightFogOn",int) = 1        
// ================================================== stencil settings
        [Group(Stencil)]
        [GroupEnum(Stencil,UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 0
        [GroupStencil(Stencil)] _Stencil ("Stencil ID", int) = 0
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)]_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255

        [Group(Alpha)]
        [GroupHeader(Alpha,AlphaTest)]
        [GroupToggle(Alpha,ALPHA_TEST)]_ClipOn("_AlphaTestOn",int) = 0
        [GroupSlider(Alpha)]_Cutoff("_Cutoff",range(0,1)) = 0.5
        
        [GroupHeader(Alpha,BlendMode)]
        [GroupPresetBlendMode(Alpha,,_SrcMode,_DstMode)]_PresetBlendMode("_PresetBlendMode",int)=0
        // [GroupEnum(Alpha,UnityEngine.Rendering.BlendMode)]
        [HideInInspector]_SrcMode("_SrcMode",int) = 1
        [HideInInspector]_DstMode("_DstMode",int) = 0

//================================================= settings
        [Group(Settings)]
		[GroupToggle(Settings)]_ZWriteMode("ZWriteMode",int) = 1
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[GroupEnum(Settings,UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4
        [GroupEnum(Settings,UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
    }

    HLSLINCLUDE
        #include "../../PowerShaderLib/Lib/UnityLib.hlsl"
        #include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
        #include "../../PowerShaderLib/Lib/GILib.hlsl"
        #include "../../PowerShaderLib/Lib/UVMapping.hlsl"
        #include "../../PowerShaderLib/URPLib/URP_Lighting.hlsl"
        #include "../../PowerShaderLib/URPLib/URP_MotionVectors.hlsl"
        #include "../../PowerShaderLib/Lib/BigShadows.hlsl"
        #include "../../PowerShaderLib/Lib/InstancingLib.hlsl"
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            float2 uv1:TEXCOORD1;
            float2 uv2:TEXCOORD2;
            float2 uv3:TEXCOORD3;
            DECLARE_MOTION_VS_INPUT(prevPos);
            float3 normal:NORMAL;
            float4 tangent:TANGENT;
            float4 color:COLOR;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float4 uv : TEXCOORD0;
            
            TANGENT_SPACE_DECLARE(1,2,3);
            float2 fogCoord:TEXCOORD4;
            // motion vectors
            DECLARE_MOTION_VS_OUTPUT(5,6);
            float4 bigShadowCoord:TEXCOORD7;
            float4 splat12UV:TEXCOORD8;
            float4 splat34UV:TEXCOORD9;

            float4 color:COLOR;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        // TEXTURE2D_ARRAY(_MainTexArray);SAMPLER(sampler_MainTexArray);
        TEXTURECUBE(_IBLCube); SAMPLER(sampler_IBLCube);

        sampler2D _BaseMap;
        sampler2D _Splat0,_Splat1,_Splat2,_Splat3,_Control;
        sampler2D _EmissionMap;
        sampler2D _PbrMask;
        sampler2D _NormalMap;

        CBUFFER_START(UnityPerMaterial)
        float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST;
        float4 _Control_ST;
        float2 _SplatEdgeRange;
        half4 _SplatColor0,_SplatColor1,_SplatColor2,_SplatColor3;
        half4 _SplatBlendWeights;
        half _SplatEdgeRangeOn;

        half4 _BaseColor;
        half _ControlMapRemainWeightOn;

        half _FogOn,_FogNoiseOn,_DepthFogOn,_HeightFogOn;
        half _Cutoff;
        half _NormalUnifiedOn;
        half _UseUV,_UseUVReverseY;
        half _MainTexArrayId;
        half _PreMulVertexColor;

        // half _EmissionOn;
        // half4 _EmissionColor;
        half _Metallic,_Smoothness,_Occlusion;
        half3 _EnvIntensity;
        half _FresnelIntensity;
        half4 _IBLCube_HDR;;
        // half _NormalScale;
        half _UV1TransformToLightmapUV;
        half _PremulAlpha,_RGBMScale;

        half _MainLightShadowSoftScale;
        half _CustomShadowNormalBias,_CustomShadowDepthBias;
        half4 _GIDiffuseColor;
        half _BigShadowOff;
        half _MainLightOn;
        CBUFFER_END

    ENDHLSL

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            blend [_SrcMode][_DstMode]
            zwrite[_ZWriteMode]
            ztest[_ZTestMode]
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
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag
            // #pragma shader_feature SIMPLE_FOG
            #pragma shader_feature ALPHA_TEST
            #pragma shader_feature MAIN_TEX_ARRAY
            #pragma shader_feature _EMISSION
            #pragma shader_feature _IBL_ON
            #pragma shader_feature NORMAL_MAP_ON
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS //_MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "../../PowerShaderLib/Lib/FogLib.hlsl"


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v,o);

                float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
                float3 worldNormal = normalize(TransformObjectToWorldNormal(v.normal));
                float3 worldTangent = normalize(TransformObjectToWorldDir(v.tangent.xyz));
                
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                float2 mainUV = TRANSFORM_TEX(v.uv, _Control);

                float2 lightmapUV = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
                float2 uv1 = GetUV1(v.uv1,lightmapUV,_UV1TransformToLightmapUV);

                o.uv.xy = GetUV(float4(mainUV,uv1),float4(v.uv2,v.uv3), _UseUV);
                o.uv.y = _UseUVReverseY ? 1 - o.uv.y : o.uv.y;
                o.uv.zw = lightmapUV;

                o.splat12UV = float4(TRANSFORM_TEX(v.uv,_Splat0) , TRANSFORM_TEX(v.uv,_Splat1));
                o.splat34UV = float4(TRANSFORM_TEX(v.uv,_Splat2) , TRANSFORM_TEX(v.uv,_Splat3));

                o.fogCoord = CalcFogFactor(worldPos.xyz,o.vertex.z,_HeightFogOn,_DepthFogOn);
                o.color = v.color;

                // output flat normal
                worldNormal.xyz = _NormalUnifiedOn ? 0.5 : worldNormal.xyz;
                TANGENT_SPACE_COMBINE_WORLD(worldPos,worldNormal,float4(worldTangent,v.tangent.w * unity_WorldTransformParams.w),o/**/);

                CALC_MOTION_POSITIONS(v.prevPos,v.vertex,o,o.vertex);

                branch_if(!_BigShadowOff){
                    float3 bigShadowCoord = TransformWorldToBigShadow(worldPos);
                    o.bigShadowCoord.xyz = bigShadowCoord;
                }
                return o;
            }

            #define SAMPLE_SPLAT(splatControl,splatColor) (splatControl * splatColor)
            /**
                Sample splats(4)
            */
            half4 SampleSplats(float4 splatControl,float4 splat12UV,float4 splat34UV,half4 vertexColor){
                half4 splat1 = tex2D(_Splat0,splat12UV.xy);
                half4 splat2 = tex2D(_Splat1,splat12UV.zw);
                half4 splat3 = tex2D(_Splat2,splat34UV.xy);
                half4 splat4 = tex2D(_Splat3,splat34UV.zw);

                return  SAMPLE_SPLAT(splatControl.x * vertexColor.x * _SplatBlendWeights.x, splat1 *_SplatColor0)
                + SAMPLE_SPLAT(splatControl.y * vertexColor.y * _SplatBlendWeights.y, splat2 *_SplatColor1)
                + SAMPLE_SPLAT(splatControl.z * vertexColor.z * _SplatBlendWeights.z, splat3 *_SplatColor2)
                + SAMPLE_SPLAT(splatControl.w * vertexColor.w * _SplatBlendWeights.w, splat4 *_SplatColor3) 
                ;
            }

            half4 frag (v2f i,out float4 outputNormal:SV_TARGET1,out float4 outputMotionVectors:SV_TARGET2) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                TANGENT_SPACE_SPLIT(i);

                float2 uv = i.uv.xy;
                float2 lightmapUV = i.uv.zw;

                // sample the texture
                half4 vertexColor = _PreMulVertexColor ? i.color : 1;
                // half4 mainTex = SampleMainTex(uv);
                float4 controlMap = tex2D(_Control,uv);
                controlMap = _SplatEdgeRangeOn ? smoothstep(_SplatEdgeRange.x,_SplatEdgeRange.y,controlMap) : controlMap;

                half4 baseMapCol = tex2D(_BaseMap, uv) * _BaseColor;
                baseMapCol *= _ControlMapRemainWeightOn ? saturate(1-length(controlMap)) : 1;
// return baseMapCol;
                half4 splatCol = SampleSplats(controlMap,i.splat12UV,i.splat34UV,i.color);
                splatCol += baseMapCol;

                float3 albedo = splatCol.xyz;
                float alpha = splatCol.w;

                // alpha premultiply and rgbm scale
                albedo =_PremulAlpha ? albedo.xyz*alpha* _RGBMScale : albedo;

                //---------- pbrMask
                float4 pbrMask = tex2D(_PbrMask,uv);
                float metallic = 0;
                float smoothness =0;
                float occlusion =0;
                SplitPbrMaskTexture(metallic/**/,smoothness/**/,occlusion/**/,pbrMask,int3(0,1,2),float3(_Metallic,_Smoothness,_Occlusion),false);

                //---------- main light
                float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
                Light mainLight = GetMainLight(shadowCoord,worldPos,_MainLightShadowSoftScale);
                branch_if(!_BigShadowOff)
                {
                    // i.bigShadowCoord.z += 0.001;
                    float atten = CalcBigShadowAtten(i.bigShadowCoord.xyz,1);
                    mainLight.shadowAttenuation = min(mainLight.shadowAttenuation,atten);
                    mainLight.distanceAttenuation = 1;// keep main light
                }
                
                //---------- normal
                #if defined(NORMAL_MAP_ON)
                    float3 tn = UnpackNormalScale(tex2D(_NormalMap,uv),_NormalScale);
                    float3 n = normalize(TangentToWorld(tn,i.tSpace0,i.tSpace1,i.tSpace2));
                    n = normalize(n+normal);
                #else
                    float3 n = normal;
                #endif

                float3 v = normalize(GetWorldSpaceViewDir(worldPos));
                float nv = saturate(dot(n,v));
                float nl = saturate(dot(n,mainLight.direction));

                half3 lightColor = _MainLightOn ? mainLight.color : 1;
                half3 radiance = lightColor * (nl * mainLight.shadowAttenuation * mainLight.distanceAttenuation);

                float3 diffColor = albedo * (1 - metallic);
                float3 specColor = lerp(0.04,albedo,metallic);
                //---------- roughness
                float roughness = 0;
                float a = 0;
                float a2 = 0;
                CalcRoughness(roughness/**/,a/**/,a2/**/,smoothness);      

                //--- custom ibl
                #if defined(_IBL_ON)
                    #define IBL_CUBE _IBLCube
                    #define IBL_CUBE_SAMPLER sampler_IBLCube
                    #define IBL_HDR _IBLCube_HDR    
                #else
                    #define IBL_CUBE unity_SpecCube0
                    #define IBL_CUBE_SAMPLER samplerunity_SpecCube0
                    #define IBL_HDR unity_SpecCube0_HDR
                #endif
                float3 giColor = 0;
                float3 giDiff = CalcGIDiff(normal,diffColor,lightmapUV);
                float3 giSpec = CalcGISpec(IBL_CUBE,
                    IBL_CUBE_SAMPLER,
                    IBL_HDR,
                    specColor,
                    worldPos,
                    n,
                    v,
                    0/*reflectDirOffset*/,
                    _EnvIntensity.xyz/*reflectIntensity*/,
                    nv,
                    roughness,
                    a2,
                    smoothness,
                    metallic,
                    half2(0,1),
                    _FresnelIntensity,
                    0,
                    0,
                    0,
                    0
                );
                giColor = (giDiff * _GIDiffuseColor.xyz + giSpec) * occlusion;
                // giColor = giSpec;
                
                half3 directColor = diffColor * radiance;

                half4 col = (half4)0;
                col.xyz = directColor + giColor;
                col.w = alpha;

            //------ emission
                half3 emissionColor = 0;
                #if defined(_EMISSION)
                    emissionColor += CalcEmission(tex2D(_EmissionMap,uv),_EmissionColor.xyz,_EmissionColor.w*_EmissionOn);
                #endif
                col.xyz += emissionColor;

                #if defined(ALPHA_TEST)
                    clip(col.w - _Cutoff);
                #endif


                //-------- output mrt
                // output world normal
                outputNormal = half4(n,0.5);
                // output motion
                outputMotionVectors = CALC_MOTION_VECTORS(i);

                BlendFogSphereKeyword(col.rgb/**/,worldPos,i.fogCoord.xy,_HeightFogOn,_FogNoiseOn,_DepthFogOn); // 2fps

                return col;
            }
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
            // #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON

            #define USE_SAMPLER2D
            // #include "Lib/PBRInput.hlsl"

            // #define _CURVED_WORLD
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
            #pragma vertex vert
            #pragma fragment frag

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma shader_feature_fragment ALPHA_TEST
            // #define _WIND_ON //#pragma shader_feature_local_vertex _WIND_ON

            #define SHADOW_PASS 
            #define USE_SAMPLER2D
            #define _MainTexChannel 3
            #define _CustomShadowNormalBias _CustomShadowNormalBias
            #define _CustomShadowDepthBias _CustomShadowDepthBias

            // #define _CURVED_WORLD
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            // rotate by Mainlight
            // float4x4 _MainLightYRot;
            // #define _MainLightYRot _CameraYRot

            // shadow_v2f vertShadow(shadow_appdata input){
            //     input.vertex.xyz = _RotateShadow ? mul(_MainLightYRot,input.vertex).xyz : input.vertex.xyz;

            //     return vert(input);
            // }

            ENDHLSL
        }
    }
}
