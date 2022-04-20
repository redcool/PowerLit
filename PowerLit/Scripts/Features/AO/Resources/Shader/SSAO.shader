Shader "Hidden/PowerFeature/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    HLSLINCLUDE
    #include "URPLib.hlsl"

    TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
    half4 _CameraDepthTexture_TexelSize;

    // Z buffer depth to linear 0-1 depth
    float LinearizeDepth(float z)
    {
        float isOrtho = unity_OrthoParams.w;
        float isPers = 1 - unity_OrthoParams.w;
        z *= _ZBufferParams.x;
        return (1 - isOrtho * z) / (isPers * z + _ZBufferParams.y);
    }


    half AO(half2 screenUV,int samples,half intensity){
        half3x3 proj = (half3x3)unity_CameraProjection;
        half2 p11_22 = half2(proj._11,proj._22);
        half2 p13_31 = half2(proj._13,proj._31);

        half depth = LinearizeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV).x);
        

        return depth;
    }

    ENDHLSL

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            half4 _MainTex_TexelSize;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                #ifdef UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                    o.uv.y = 1-o.uv.y;
                #endif
                return o;
            }

            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);
            half _Samples,_Intensity;


            half4 frag (v2f i) : SV_Target
            {
                // return half4(i.uv,0,0);
                // return SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                return AO(i.uv,_Samples,_Intensity);
            }
            ENDHLSL
        }
    }
}
