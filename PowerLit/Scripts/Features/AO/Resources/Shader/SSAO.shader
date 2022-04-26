Shader "Hidden/PowerFeature/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _SampleCount("_SampleCount",float) = 6
        _Intensity("_Intensity",float) = 1
        _Radius("_Radius",float) = 3
        _Downsample("_Downsample",float) = 1
    }

    HLSLINCLUDE
    #include "URPLib.hlsl"

    // By default, a fixed sampling pattern is used in the AO estimator. Although
    // this gives preferable results in most cases, a completely random sampling
    // pattern could give aesthetically better results. Disable the macro below
    // to use such a random pattern instead of the fixed one.
    #define FIX_SAMPLING_PATTERN

    // The SampleNormal function normalizes samples from G-buffer because
    // they're possibly unnormalized. We can eliminate this if it can be said
    // that there is no wrong shader that outputs unnormalized normals.
    // #define VALIDATE_NORMALS

    #define UNITY_PI 3.1415926
    // The constant below determines the contrast of occlusion. This allows
    // users to control over/under occlusion. At the moment, this is not exposed
    // to the editor because it’s rarely useful.
    static const float kContrast = 0.6;

    // The constant below controls the geometry-awareness of the bilateral
    // filter. The higher value, the more sensitive it is.
    static const float kGeometryCoeff = 0.8;

    // The constants below are used in the AO estimator. Beta is mainly used
    // for suppressing self-shadowing noise, and Epsilon is used to prevent
    // calculation underflow. See the paper (Morgan 2011 http://goo.gl/2iz3P)
    // for further details of these constants.
    static const float kBeta = 0.002;
    static const float kEpsilon = 1e-4;


    TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);
    half4 _CameraDepthTexture_TexelSize;

    half _SampleCount,_Intensity,_Radius,_Downsample;

    // Z buffer depth to linear 0-1 depth
    float LinearizeDepth(float z)
    {
        float isOrtho = unity_OrthoParams.w;
        float isPers = 1 - unity_OrthoParams.w;
        z *= _ZBufferParams.x;
        return (1 - isOrtho * z) / (isPers * z + _ZBufferParams.y);
    }

    // Boundary check for depth sampler
    // (returns a very large value if it lies out of bounds)
    half CheckBounds(half2 uv, half d)
    {
        half ob = any(uv < 0) + any(uv > 1);
    #if defined(UNITY_REVERSED_Z)
        ob += (d <= 0.00001);
    #else
        ob += (d >= 0.99999);
    #endif
        return ob * 1e8;
    }

    half SampleDepth(half2 uv){
        half d = LinearizeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,uv).x);
        return d * _ProjectionParams.z + CheckBounds(uv,d);
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
        return frac(sin(dot(half2(12.9898, 78.233),uv)) * 43758.5453);
    }

    // Interleaved gradient function from Jimenez 2014 http://goo.gl/eomGso
    half GradientNoise(half2 uv){
        uv = floor(uv * _ScreenParams.xy);
        half f = dot(half2(0.06711056,0.00583715),uv);
        return frac(52.9829189f * frac(f));
    }

    half3 PickSamplePoint(half2 uv,half index){
        #if defined(FIX_SAMPLING_PATTERN)
            half gn = GradientNoise(uv * _Downsample);
            half u = frac(N21(half2(0,index))+gn) * 2-1;
            half theta = (N21(half2(1,index))+gn)*UNITY_PI*2;
        #else
            half u = N21(uv+half2(_Time.x,index)) * 2-1;
            half theta = N21(half2(-uv.x - _Time.x,uv.y + index)) * UNITY_PI * 2;
        #endif
        half3 v = half3(CosSin(theta) * sqrt(1 - u*u),u);
        half l = sqrt( (index+1)/_SampleCount ) * _Radius;
        return v * l;
    }

    half4 PackAONormal(half ao,half3 n){
        return half4(ao,n*0.5+0.5);
    }

    half GetPackedAO(half4 x){
        return x.x;
    }
    half3 GetPackedNormal(half4 x){
        return x.yzw * 2 - 1;
    }
    half CompareNormal(half3 n1,half3 n2){
        return smoothstep(kGeometryCoeff,1,dot(n1,n2));
    }

    //
    // Distance-based AO estimator based on Morgan 2011 http://goo.gl/2iz3P
    //

    half4 AO(half2 uv){
        half3x3 proj = (half3x3)unity_CameraProjection;
        half2 p11_22 = half2(proj._11,proj._22);
        half2 p13_23 = half2(proj._13,proj._23);

        half depth_o = SampleDepth(uv);
        half3 vpos_o = ReconstructViewPos(uv,depth_o,p11_22,p13_23);
        half3 norm_o = normalize(cross(ddy(vpos_o),ddx(vpos_o)));

        half ao = 0;
        for(int s=0;s<_SampleCount;s++){
            // Sample point
            #if defined(SHADER_API_D3D11)
                    // This 'floor(1.0001 * s)' operation is needed to avoid a NVidia
                    // shader issue. This issue is only observed on DX11.
                    float3 v_s1 = PickSamplePoint(uv, floor(1.0001 * s));
            #else
                    float3 v_s1 = PickSamplePoint(uv, s);
            #endif
            v_s1 = faceforward(v_s1,-norm_o,v_s1);

            half3 vpos_s1 = vpos_o + v_s1;

            //reproject point
            half3 spos_s1 = mul(proj,vpos_s1);
            half2 uv_s1 = (spos_s1.xy / CheckPerspective(vpos_s1.z)+1) * 0.5;
            // #if defined(UNITY_SINGLE_PASS_STEREO)
                    // float2 uv_s1 = UnityStereoScreenSpaceUVAdjust(uv_s1_01, _MainTex_ST);
            // #endif
            half depth_s1 = SampleDepth(uv_s1);
            half3 vpos_s2 = ReconstructViewPos(uv_s1,depth_s1,p11_22,p13_23);
            half3 v_s2 = vpos_s2 - vpos_o;
            
            half a1 = max(dot(v_s2,norm_o) - kBeta * depth_o,0);
            half a2 = dot(v_s2,v_s2) + kEpsilon;
            ao += a1/a2;
        }
        ao *= _Radius;
        ao = pow(ao * _Intensity / _SampleCount,kContrast);
// return GradientNoise(uv);
        // return depth;
        return PackAONormal(ao,norm_o);
    }

    half4 Blur(half2 uv,TEXTURE2D_PARAM(tex,_sampler),half2 delta){
        const static half DELTAS[2] = {1.3333,3.2222};
        const static half WEIGHTS[2] = {0.3,0.1};

        half4 t0 = SAMPLE_TEXTURE2D(tex,_sampler,uv);
        half3 n0 = GetPackedNormal(t0);
        half weight = 0.2;
        half ao = 0;

        for(int s=0;s<2;s++){
            half4 t1 = SAMPLE_TEXTURE2D(tex,_sampler,uv - delta * DELTAS[s]);
            half4 t2 = SAMPLE_TEXTURE2D(tex,_sampler,uv + delta * DELTAS[s]);
            
            half w1 = CompareNormal(n0,GetPackedNormal(t1)) * WEIGHTS[s];
            half w2 = CompareNormal(n0,GetPackedNormal(t2)) * WEIGHTS[s];

            ao += GetPackedAO(t1) * w1 + GetPackedAO(t2) * w2;
            weight += w1 + w2;
        }

        return PackAONormal(ao / weight,n0);
    }

//-------------------------------------
TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);
half4 _MainTex_TexelSize;

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

    ENDHLSL

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always Cull Off ZWrite Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            half4 frag (v2f i) : SV_Target
            {
                // return half4(i.uv,0,0);
                // return SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                return AO(i.uv);
            }
            ENDHLSL
        }

        Pass
        {
            ZTest Always Cull Off ZWrite Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            half4 frag (v2f i) : SV_Target
            {
                return Blur(i.uv,_MainTex,sampler_MainTex,half2(_MainTex_TexelSize.x * 2,0));
            }
            ENDHLSL
        }

        Pass
        {
            ZTest Always Cull Off ZWrite Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            half4 frag (v2f i) : SV_Target
            {
                return Blur(i.uv,_MainTex,sampler_MainTex,half2(0,_MainTex_TexelSize.y * 2));
            }
            ENDHLSL
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            TEXTURE2D(_SSAOTexture);SAMPLER(sampler_SSAOTexture);
            
            half4 frag (v2f i) : SV_Target
            {
                half4 mainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                half4 aoTex = SAMPLE_TEXTURE2D(_SSAOTexture,sampler_SSAOTexture,i.uv);

                half ao = GetPackedAO(aoTex);
                half3 n0 = GetPackedNormal(aoTex);

                mainTex.xyz *= 1 - ao;
                return mainTex;
            }
            ENDHLSL
        }        
    }
}
