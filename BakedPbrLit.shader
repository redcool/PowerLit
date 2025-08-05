Shader "URP/BakedPbrLit"
{
    Properties
    {
        [Group(Main)]
        [GroupItem(Main)] _MainTex ("Texture", 2D) = "white" {}
        [GroupEnum(Main,uv0 0 uv1 1 uv2 2 uv3 3,,sample texture use uv uv1 uv2 uv3)] _UseUV ("_UseUV", range(0,3)) = 0
        [GroupToggle(Main,,uv1 y reverse)] _UseUVReverseY ("_UseUVReverseY", float) = 0
        [GroupToggle(Main,,uv1 transform to scene lightmao uv)] _UV1TransformToLightmapUV ("_UV1TransformToLightmapUV", float) = 0
        
        [GroupItem(Main)] [hdr] _Color("_Color",color) = (1,1,1,1)
        [GroupToggle(Main,,preMulti vertex color)] _PreMulVertexColor ("_PreMulVertexColor", float) = 0
        [GroupHeader(Main,PreMulAlpha)]
// ================================================== premul alpha and rgbm
        [GroupToggle(Main,,preMulti alpha)] _PremulAlpha ("_PremulAlpha", float) = 0
        [GroupSlider(Main,rgbm scale,float)] _RGBMScale ("_RGBMScale", range(0,8)) = 2

// ================================================== main texture array
        [GroupHeader(Main,MainTexArray)]
        [GroupToggle(Main,MAIN_TEX_ARRAY,mainTex use tex1DARRAY)] _MainTexArrayOn ("_MainTexArrayOn", float) = 0
        [GroupItem(Main)] _MainTexArray ("_MainTexArray", 2DArray) = "white" {}
        [GroupSlider(Main,texArr id,int)] _MainTexArrayId ("_MainTexArrayId", range(0,16)) = 0
// ================================================== pbrMask        
        [Group(PBR Mask)]
        [GroupItem(PBR Mask)]_PbrMask("_PbrMask",2d)="white"{}

        [GroupItem(PBR Mask)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(PBR Mask)]_Occlusion("_Occlusion",range(0,1)) = 0

//================================================= Normal
        [Group(Normal)]
        [GroupItem(Normal)]_NormalMap("_NormalMap",2d)="bump"{}
        [GroupItem(Normal)]_NormalScale("_NormalScale",range(0,5)) = 1        
        [GroupToggle(Normal, ,output flat normal force)]_NormalUnifiedOn("_NormalUnifiedOn",int) = 0
//================================================= emission
        [Group(Emission)]
        [GroupToggle(Emission,_EMISSION)]_EmissionOn("_EmissionOn",int) = 0  //_EMISSION
        [GroupItem(Emission)]_EmissionMap("_EmissionMap(rgb:Color,a:Mask)",2d)=""{}
        [hdr][GroupItem(Emission)]_EmissionColor("_EmissionColor(w:mask)",color) = (0,0,0,0)
        [GroupMaterialGI(Emission)]_EmissionGI("_EmissionGI",int) = 0
//================================================= Env
        [Group(Env)]
        [GroupHeader(Env,Custom IBL)]
        [GroupToggle(Env,_IBL_ON)]_IBLOn("_IBLOn",float) = 0
        [GroupItem(Env)][NoScaleOffset]_IBLCube("_IBLCube",cube) = ""{}
        
        [GroupHeader(Env,IBL Params)]
        [GroupItem(Env)]_EnvIntensity("_EnvIntensity",float) = 1
        [GroupItem(Env)]_FresnelIntensity("_FresnelIntensity",float) = 1
// ================================================== Fog
        [Group(Fog)]
        [GroupToggle(Fog)]_FogOn("_FogOn",int) = 1
        [GroupToggle(Fog,SIMPLE_FOG,use simple linear depth height fog)]_SimpleFog("_SimpleFog",int) = 0
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
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature SIMPLE_FOG
            #pragma shader_feature ALPHA_TEST
            #pragma shader_feature MAIN_TEX_ARRAY
            #pragma shader_feature _EMISSION
            #pragma shader_feature _IBL_ON

            #include "../PowerShaderLib/Lib/UnityLib.hlsl"
            #include "../PowerShaderLib/Lib/MaterialLib.hlsl"
            #include "../PowerShaderLib/Lib/GILib.hlsl"
            #include "../PowerShaderLib/Lib/UVMapping.hlsl"
            #include "../PowerShaderLib/URPLib/URP_MotionVectors.hlsl"

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
                float4 color:COLOR;
            };

            TEXTURE2D_ARRAY(_MainTexArray);SAMPLER(sampler_MainTexArray);
            TEXTURECUBE(_IBLCube); SAMPLER(sampler_IBLCube);
            sampler2D _MainTex;
            sampler2D _EmissionMap;
            sampler2D _PbrMask;
            sampler2D _NormalMap;

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _Color;
            half _FogOn,_FogNoiseOn,_DepthFogOn,_HeightFogOn;
            half _Cutoff;
            half _NormalUnifiedOn;
            half _UseUV,_UseUVReverseY;
            half _MainTexArrayId;
            half _PreMulVertexColor;

            half _EmissionOn;
            half4 _EmissionColor;
            half _Metallic,_Smoothness,_Occlusion;
            half _EnvIntensity;
            half _FresnelIntensity;
            half4 _IBLCube_HDR;;
            half _NormalScale;
            half _UV1TransformToLightmapUV;
            half _PremulAlpha,_RGBMScale;
            CBUFFER_END
            
            #include "../PowerShaderLib/Lib/FogLib.hlsl"


            v2f vert (appdata v)
            {
                float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
                float3 worldNormal = normalize(TransformObjectToWorldNormal(v.normal));
                float3 worldTangent = normalize(TransformObjectToWorldDir(v.tangent.xyz));
                
                v2f o = (v2f)0;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                float2 mainUV = TRANSFORM_TEX(v.uv, _MainTex);
                float2 lightmapUV = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
                float2 uv1 = GetUV1(v.uv1,lightmapUV,_UV1TransformToLightmapUV);

                o.uv.xy = GetUV(float4(mainUV,uv1),float4(v.uv2,v.uv3), _UseUV);
                o.uv.y = _UseUVReverseY ? 1 - o.uv.y : o.uv.y;
                o.uv.zw = lightmapUV;

                o.fogCoord = CalcFogFactor(worldPos.xyz,o.vertex.z,_HeightFogOn,_DepthFogOn);
                o.color = v.color;

                // output flat normal
                worldNormal.xyz = _NormalUnifiedOn ? 0.5 : worldNormal.xyz;
                TANGENT_SPACE_COMBINE_WORLD(worldPos,worldNormal,float4(worldTangent,v.tangent.w * unity_WorldTransformParams.w),o/**/);

                CALC_MOTION_POSITIONS(v.prevPos,v.vertex,o,o.vertex);
                return o;
            }

            half4 SampleMainTex(float2 uv){
                #if defined(MAIN_TEX_ARRAY)
                // half4 tex = tex2DARRAY(_MainTexArray,float3(uv,_MainTexArrayId));
                half4 tex = SAMPLE_TEXTURE2D_ARRAY(_MainTexArray,sampler_MainTexArray,uv,_MainTexArrayId);
                #else
                half4 tex = tex2D(_MainTex, uv);
                #endif
                return tex;
            }

            float4 frag (v2f i,out float4 outputNormal:SV_TARGET1,out float4 outputMotionVectors:SV_TARGET2) : SV_Target
            {
                TANGENT_SPACE_SPLIT(i);

                float2 uv = i.uv.xy;
                
                // sample the texture
                half4 vertexColor = _PreMulVertexColor ? i.color : 1;
                half4 mainTex = SampleMainTex(uv);
                half4 mainTexCol = mainTex * _Color * vertexColor;
                float3 albedo = mainTexCol.xyz;
                float alpha = mainTexCol.w;

                // alpha premultiply and rgbm scale
                albedo =_PremulAlpha ? mainTex.xyz*mainTex.w* _RGBMScale : albedo;

                //---------- pbrMask
                float4 pbrMask = tex2D(_PbrMask,uv);
                float metallic = 0;
                float smoothness =0;
                float occlusion =0;
                SplitPbrMaskTexture(metallic/**/,smoothness/**/,occlusion/**/,pbrMask,int3(0,1,2),float3(_Metallic,_Smoothness,_Occlusion),false);

                //---------- normal
                float3 tn = UnpackNormalScale(tex2D(_NormalMap,uv),_NormalScale);
                float3 n = normalize(TangentToWorld(tn,i.tSpace0,i.tSpace1,i.tSpace2));
                
                float3 v = normalize(GetWorldSpaceViewDir(worldPos));
                float nv = saturate(dot(n,v));

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
                // float3 giDiff = CalcGIDiff(normal,diffColor,lightmapUV);
                float3 giSpec = CalcGISpec(IBL_CUBE,
                    IBL_CUBE_SAMPLER,
                    IBL_HDR,
                    specColor,
                    worldPos,
                    n,
                    v,
                    0/*reflectDirOffset*/,
                    _EnvIntensity/*reflectIntensity*/,
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
                // giColor = (giDiff * _LightmapColor.xyz + giSpec) * occlusion;
                giColor = giSpec;
                
                half3 directColor = diffColor;

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
    }
}
