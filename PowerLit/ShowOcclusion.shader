Shader "Character/Unlit/ShowOcclusion"
{
    Properties
    {
        _OcclusionColor("_OcclusionColor",color) = (0,0.2,0.5,1)
        
        [GroupVectorSlider(,x y, 0_5 0_5)]
        _NoiseScale("_NoiseScale",vector) = (0,1,0,0)

        [GroupSlider(_)]_NoiseSpeed("_NoiseSpeed",range(0,2)) = 0.2
        [GroupToggle(_,_CLIP_ON)]_Clip("_Clip",int) = 0

        [Group(Weather)]
        [GroupToggle(Weather)]_FogOn("_FogOn",int) = 0
    }

HLSLINCLUDE
            #include "../../PowerShaderLib/Lib/UnityLib.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD1;
                float4 fogCoord:TEXCOORD2;
            };
            CBUFFER_START(UnityPerMaterial)
            half _FogOn;
            float2 _NoiseScale;
            half4 _OcclusionColor;
            float _NoiseSpeed;
            CBUFFER_END

            #include "../../PowerShaderLib/Lib/FogLib.hlsl"

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Random.hlsl"

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.fogCoord.xy = CalcFogFactor(o.worldPos);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 screenUV = (i.vertex.xy/_ScreenParams.xy * 10);
                float intensity = InterleavedGradientNoise(screenUV.xy * _NoiseScale.xy + _NoiseSpeed * _Time.y,0);

                #if defined(_CLIP_ON)
                clip(intensity - 0.5);
                #endif

                float4 col = _OcclusionColor * intensity;
                BlendFogSphereKeyword(col.rgb/**/,i.worldPos,i.fogCoord.xy,true,false,true); // 2fps
                return col;
            }
ENDHLSL

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            // ztest greater

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _CLIP_ON


            ENDHLSL
        }
    }
}
