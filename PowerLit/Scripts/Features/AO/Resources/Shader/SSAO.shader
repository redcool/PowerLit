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

    half SampleDepth(half2 screenUV){
        return LinearizeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenUV).x);
    }

    // Check if the camera is perspective.
    // (returns 1.0 when orthographic)
    half CheckPerspective(half x){
        return lerp(x,1, unity_OrthoParams.w);
    }

    half3 ReconstructViewPos(half2 uv,half depth,half2 p11_22,half2 p13_23){
        return half3( ((uv*2-1) - p13_23)/p11_22 * CheckPerspective(depth),depth);
    }

    half2 CosSin(half a){
        half s,c;
        sincos(a,s,c);
        return half2(c,s);
    }

    half N21(half2 uv){
        return frac(sin(dot(half2(12.789,78.234),uv)) * 43567.345);
    }

    // Interleaved gradient function from Jimenez 2014 http://goo.gl/eomGso
    half GradientNoise(half2 uv){
        uv = floor(uv * _ScreenParams.xy);
        half f = dot(half2(0.06711056,0.00583715),uv);
        return frac(52.9829189f * frac(f));
    }

    half3 PickSamplePoint(half2 uv,half index){
        #if defined(FIX_SAMPLING_PATTERN)
            
        #endif
        return 0;
    }

    half AO(half2 uv,int samples,half intensity){
        half3x3 proj = (half3x3)unity_CameraProjection;
        half2 p11_22 = half2(proj._11,proj._22);
        half2 p13_23 = half2(proj._13,proj._23);

        half depth = SampleDepth(uv);
        half3 vpos_o = ReconstructViewPos(uv,depth,p11_22,p13_23);
        half3 norm_o = normalize(cross(ddy(vpos_o),ddx(vpos_o)));

        half ao = 0;
        for(int s=0;s<samples;s++){
            half3 v_s1 = PickSamplePoint(uv,s);

        }
return GradientNoise(uv);
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
