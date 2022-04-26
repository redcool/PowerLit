//
// Kino/Obscurance - Screen space ambient obscurance image effect
//
// Copyright (C) 2016 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#include "Common.cginc"

// Trigonometric function utility
half2 CosSin(half theta)
{
    half sn, cs;
    sincos(theta, sn, cs);
    return half2(cs, sn);
}

// Pseudo random number generator with 2D coordinates
// half UVRandom(half u, half v)
// {
//     half f = dot(half2(12.9898, 78.233), half2(u, v));
//     return frac(43758.5453 * sin(f));
// }

half N21(half2 uv){
    return frac(sin(dot(half2(12.9898, 78.233),uv)) * 43758.5453);
}

// Interleaved gradient function from Jimenez 2014 http://goo.gl/eomGso
half GradientNoise(half2 uv)
{
    uv = floor(uv * _ScreenParams.xy);
    half f = dot(half2(0.06711056f, 0.00583715f), uv);
    return frac(52.9829189f * frac(f));
}

// Check if the camera is perspective.
// (returns 1.0 when orthographic)
half CheckPerspective(half x)
{
    return lerp(x, 1, unity_OrthoParams.w);
}

// Reconstruct view-space position from UV and depth.
// p11_22 = (unity_CameraProjection._11, unity_CameraProjection._22)
// p13_31 = (unity_CameraProjection._13, unity_CameraProjection._23)
half3 ReconstructViewPos(half2 uv, half depth, half2 p11_22, half2 p13_31)
{
    return half3((uv * 2 - 1 - p13_31) / p11_22 * CheckPerspective(depth), depth);
}

// Sample point picker
half3 PickSamplePoint(half2 uv, half index)
{
    // Uniformaly distributed points on a unit sphere http://goo.gl/X2F1Ho
#if defined(FIX_SAMPLING_PATTERN)
    half gn = GradientNoise(uv * _Downsample);
    half u = frac(N21(half2(0, index)) + gn) * 2 - 1;
    half theta = (N21(half2(1, index)) + gn) * UNITY_PI * 2;
#else
    half u = N21(uv + half2(_Time.x,index)) * 2 - 1;
    half theta = N21(half2(-uv.x - _Time.x, uv.y + index)) * UNITY_PI * 2;
#endif
    half3 v = half3(CosSin(theta) * sqrt(1 - u * u), u);
    // Make them distributed between [0, _Radius]
    half l = sqrt((index + 1) / _SampleCount) * _Radius;
    return v * l;
}

//
// Distance-based AO estimator based on Morgan 2011 http://goo.gl/2iz3P
//
half4 frag_ao(v2f i) : SV_Target
{
    half2 uv = i.uvAlt;
    // half2 uv01 = i.uv01;

    // Parameters used in coordinate conversion
    half3x3 proj = (half3x3)unity_CameraProjection;
    half2 p11_22 = half2(proj._11, proj._22);
    half2 p13_31 = half2(proj._13, proj._23);

    // View space normal and depth
    half3 norm_o = 0;
    half depth_o = SampleDepth(uv);

#if defined(SOURCE_DEPTHNORMALS)
    // Offset the depth value to avoid precision error.
    // (depth in the DepthNormals mode has only 16-bit precision)
    depth_o -= _ProjectionParams.z / 65536;
#endif

    // Reconstruct the view-space position.
    half3 vpos_o = ReconstructViewPos(uv, depth_o, p11_22, p13_31);
norm_o = normalize(cross(ddy(vpos_o),ddx(vpos_o)));
    half ao = 0.0;

    for (int s = 0; s < _SampleCount; s++)
    {
        // Sample point
// #if defined(SHADER_API_D3D11)
//         // This 'floor(1.0001 * s)' operation is needed to avoid a NVidia
//         // shader issue. This issue is only observed on DX11.
//         half3 v_s1 = PickSamplePoint(uv, floor(1.0001 * s));
// #else
        half3 v_s1 = PickSamplePoint(uv, s);
// #endif
        v_s1 = faceforward(v_s1, -norm_o, v_s1);

        half3 vpos_s1 = vpos_o + v_s1;
        // Reproject the sample point
        half3 spos_s1 = mul(proj, vpos_s1);
        half2 uv_s1 = (spos_s1.xy / CheckPerspective(vpos_s1.z) + 1) * 0.5;
// #if defined(UNITY_SINGLE_PASS_STEREO)
//         half2 uv_s1 = UnityStereoScreenSpaceUVAdjust(uv_s1_01, _MainTex_ST);
// #else
//         half2 uv_s1 = uv_s1_01;
// #endif

        // Depth at the sample point
        half depth_s1 = SampleDepth(uv_s1);

        // Relative position of the sample point
        half3 vpos_s2 = ReconstructViewPos(uv_s1, depth_s1, p11_22, p13_31);
        half3 v_s2 = vpos_s2 - vpos_o;

        // Estimate the obscurance value
        half a1 = max(dot(v_s2, norm_o) - kBeta * depth_o, 0);
        half a2 = dot(v_s2, v_s2) + kEpsilon;
        ao += a1 / a2;
    }

    ao *= _Radius; // intensity normalization

    // Apply other parameters.
    ao = pow(ao * _Intensity / _SampleCount, kContrast);

    return PackAONormal(ao, norm_o);
}
