Shader "Skybox/Sky1"
{
    Properties
    {
    [Group(Main)]
    // [GroupItem(Main)]_SunSize ("Sun Size", Range(0,1)) = 0.04
    // [GroupItem(Main)]_SunSizeConvergence("Sun Size Convergence", Range(1,10)) = 5
    [GroupVectorSlider(Main,min max,0_1 0_1,sun halo range)]_SunSizeRange ("Sun Size Range", Vector) = (0.9,1,0,0)

    [GroupItem(Main)]_AtmosphereThickness ("Atmosphere Thickness", Range(0,5)) = 1.0
    [GroupItem(Main)]_SkyTint ("Sky Tint", Color) = (.5, .5, .5, 1)
    [GroupItem(Main)]_GroundColor ("Ground", Color) = (.369, .349, .341, 1)

    [GroupItem(Main)]_Exposure("Exposure", Range(0, 8)) = 1.3
    // [GroupItem(Main)]_MoonSize ("Moon Size", Range(0,1)) = 0.04
    [GroupVectorSlider(Main,min max,0_1 0_1,moon halo range)] _MoonSizeRange ("Moon Size Range", Vector) = (0.999,1,0,0)
    }

    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define DRP
            #include "../../PowerShaderLib/Lib/UnityLib.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half _Exposure;
                half3 _GroundColor;
                // half _SunSize;
                // half _SunSizeConvergence;
                half3 _SkyTint;
                half _AtmosphereThickness;
                half2 _SunSizeRange;
                // half _MoonSize;
                half2 _MoonSizeRange;
            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };


            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos:TEXCOORD0;
                half3 groundColor:TEXCOORD1;
                half3 skyColor : TEXCOORD2;
                half3 sunColor : TEXCOORD3;
            };

            // RGB wavelengths
            // .35 (.62=158), .43 (.68=174), .525 (.75=190) 
            //浅蓝色
            static const float3 kDefaultScatteringWavelength = float3(.65, .57, .475);
            //深灰色
            static const float3 kVariableRangeForScatteringWavelength = float3(.15, .15, .15);

            /**
                大气层5层 : (对流(<12km),平流(<48),中间(<85km),热层(<800km),散逸层(<1000km))
                这里是相对地球半径的比例,相当于 平流层半径比例
            */
            #define OUTER_RADIUS 1.025
            static const float kOuterRadius = OUTER_RADIUS;
            static const float kOuterRadius2 = OUTER_RADIUS*OUTER_RADIUS; // 1.050625
            /**
                地球,半径比例
            */
            static const float kInnerRadius = 1.0;
            static const float kInnerRadius2 = 1.0;

            static const float kCameraHeight = 0.0001;

            // #define kRAYLEIGH (lerp(0.0, 0.0025, pow(_AtmosphereThickness,2.5)))      // Rayleigh constant
            #define kRAYLEIGH (0.0025 * pow(_AtmosphereThickness,2.5))      // Rayleigh constant [0,0.0025]
            #define kMIE 0.0010             // Mie constant
            #define kSUN_BRIGHTNESS 20.0    // Sun brightness

            #define kMAX_SCATTER 50.0 // Maximum scattering value, to prevent math overflows on Adrenos

            static const half kHDSundiskIntensityFactor = 15.0;
            // static const half kSimpleSundiskIntensityFactor = 27.0;

            static const half kSunScale = 400.0 * kSUN_BRIGHTNESS; //8000
            static const float kKmESun = kMIE * kSUN_BRIGHTNESS; //0.02
            static const float kKm4PI = kMIE * 4.0 * 3.14159265; // 0.012
            static const float kScale = 1.0 / (OUTER_RADIUS - 1.0); // 1/0.025 = 40
            static const float kScaleDepth = 0.25;
            static const float kScaleOverScaleDepth = (1.0 / (OUTER_RADIUS - 1.0)) / 0.25;// 40/0.25=160
            static const float kSamples = 2.0; // THIS IS UNROLLED MANUALLY, DON'T TOUCH

            /** 
                MIE_G : 米氏(大颗粒)散射的各向异性参数（Anisotropy Factor）,
                值域[-1,1],  
                    -1 : 向后散射, 
                    0 : 均匀散射
                    1 : 向前散射

                MIE_G2 常用于亨耶-格林斯坦相位函数（Henyey-Greenstein Phase Function）: hgPhase
            */
            #define MIE_G (-0.99)
            #define MIE_G2 0.9801

            #define SKY_GROUND_THRESHOLD 0.02
            /**
                相函数,描述光线被粒子散射后的分布.

                RayLeight phase
                    空气中氮氧分子(半径<可见光波长)对光线的散射,呈现均匀分布
                MIE phase
                    灰尘(粒子半径>=可见光波长)对光线的散射.主要向前散射(雾气中的车灯)
                
                hg phase(henYey-greenstein phase)
                    可调参数的散射函数,用来模拟rayLeigh与mie散射,次表面等各类散射.

                    各向异性参数（g）的变量来控制散射的方向性。
                        当 g=0 时，HG 相位函数近似瑞利散射的对称性，光线均匀向四面八方散射。
                        当 g>0 时，它模拟米氏散射，光线主要向前散射。
                        当 g<0 时，它表示光线主要向后散射。
            */
            // Calculates the Rayleigh phase function
            half getRayleighPhase(half eyeCos2)
            {
                return 0.75 + 0.75*eyeCos2;
            }
            half getRayleighPhase(half3 light, half3 ray)
            {
                half eyeCos = dot(light, ray);
                return getRayleighPhase(eyeCos * eyeCos);
            }

            // hg phase的改进版, MIE_G2:-0.99,为后散射
            // Calculates the Mie phase function
            half getMiePhase(float eyeCos, float eyeCos2,float sunSize)
            {
                half x = 1.0 + MIE_G2 - 2.0 * MIE_G * eyeCos;
                x = pow(x, pow(sunSize,0.65) * 10);
                x = max(x,1.0e-4); // prevent division by zero, esp. in half precision
                x = 1.5 * ((1.0 - MIE_G2) / (2.0 + MIE_G2)) * (1.0 + eyeCos2) / x;
                // x = (1-MIE_G2)/x*0.6;

                return x;
            }
            // float calcSunAttenuation(float3 lightDir,float3 ray){
            //     float focusedEyeCos = pow(saturate(dot(lightDir,ray)),5); //_SunSizeConvergence
            //     return getMiePhase(-focusedEyeCos,focusedEyeCos * focusedEyeCos,_SunSize);
            // }

            // Calc HG phase
            float HenyeyGreenstein(float g, float cosTheta/* dot(lightDir,viewDir)*/) {
                float g2 = g * g;
                float numerator = 1.0 - g2;
                float denominator = 1.0 + g2 - 2.0 * g * cosTheta;
                return numerator / pow(denominator, 1.5);
                // return numerator / pow(denominator, 1.5)/12;
            }

            /**
                range : [0.99,1]
                sunSize : [0,1]
            */
            float CalcSunAtten(float3 lightDir,float3 ray,float2 range){
                float lr = saturate(dot(lightDir,ray));
                lr = smoothstep(range.x,range.y,lr);

                return HenyeyGreenstein(0.999,lr);
            }
                    
            /**
                https://www.desmos.com/calculator/xk0tctqsui?lang=zh-CN
                
                f(x) = A exp(P(x))

                霍纳法则的形式 P(x) = ax4 + bx3 + cx2 + dx + e
                最终数值如下:
                0.25 * exp(5.25x4 - 6.80x3 +3.83x2 + 0.459x -0.00287)

            */
            float scale(float inCos)
            {
                float x = 1.0 - inCos;
                // return 0.1 * exp(x*x*x*x*5); // simple exp curve, more red
                return 0.25 * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
            }

            void CalcSkyInOut(inout half3 cIn,inout half3 cOut,float3 eyeRay,float3 cameraPos,float3 kInvWavelength,float kKrESun,float kKr4PI){
                // sky
                // Calculate the length of the "atmosphere" ,sqrt(1.05 + 1. * [-1,1]*[-1,1] - 1.) - 1.0 * [-1,1] = [2.05,0.22,1.05]
                float far = sqrt(kOuterRadius2+kInnerRadius2*eyeRay.y*eyeRay.y-kInnerRadius2) - kInnerRadius * eyeRay.y;
                // far = 0.15;

                float height = kInnerRadius + kCameraHeight; //1.0001
                float depth = exp(kScaleOverScaleDepth * -kCameraHeight); // exp(-0.016) =0.98
                float startAngle = dot(eyeRay,cameraPos); //[-1,1]
                float startOffset = depth * scale(startAngle);

                float sampleLength = far/kSamples;
                float scaledLength = sampleLength * kScale; // len * 40 ,
                float3 sampleRay = eyeRay * sampleLength;
                float3 samplePoint = cameraPos + sampleRay * 0.5;

                float3 frontColor = 0;
                // [unroll(2)]
                // for(int i=0;i<(int)kSamples;i++)
                {
                    float height = length(samplePoint);
                    float depth = exp(kScaleOverScaleDepth * (kInnerRadius - height));
                    float lightAngle = dot(_WorldSpaceLightPos0.xyz,samplePoint);
                    float cameraAngle = dot(eyeRay,samplePoint);

                    float scatter = (startOffset + depth*(scale(lightAngle) - scale(cameraAngle)));
                    scatter = depth * scale(startAngle) + (scale(lightAngle) ); // simple curve
                    scatter = clamp(scatter,0,kMAX_SCATTER);

                    float3 attenuate = exp(-scatter * (kInvWavelength * kKr4PI + kKm4PI));

                    frontColor += attenuate * depth * scaledLength;
                    // frontColor = attenuate * scaledLength;

                    samplePoint += sampleRay;
                }
                cIn = frontColor * kInvWavelength * kKrESun;
                cOut = frontColor * kKmESun;
            }

            /**
                sky color kernel
            */
            void CalcSkyInOut2(inout half3 cIn,inout half3 cOut,float3 eyeRay,float3 cameraPos,float3 kInvWavelength,float kKrESun,float kKr4PI){
                float far = sqrt(kOuterRadius2+kInnerRadius2*eyeRay.y*eyeRay.y-kInnerRadius2) - kInnerRadius * eyeRay.y;
                float sampleLength = far/kSamples;
                float scaledLength = sampleLength * kScale; // len * 40 ,

                float3 startCos = dot(eyeRay,cameraPos); // ray,view
                float3 sampleRay = eyeRay * .02;
                float3 samplePoint = cameraPos + sampleRay;

                float  lightCos = dot(_WorldSpaceLightPos0,samplePoint);
                float scatter = scale(startCos) + scale(lightCos);
                scatter = clamp(scatter,0,kMAX_SCATTER);
                
                float3 atten = exp(-scatter * (kInvWavelength * kKr4PI + kKm4PI));

                half3 frontColor = atten * scaledLength;

                cIn = frontColor * kInvWavelength * kKrESun;
                cOut = frontColor * kKmESun;
            }

            void CalcGroundInOut(inout half3 cIn,inout half3 cOut,float3 eyeRay,float3 cameraPos,float3 kInvWavelength,float kKrESun,float kKr4PI){
                //ground 
                float far = -kCameraHeight/min(-0.001,eyeRay.y);
                float3 pos = cameraPos + far * eyeRay;

                float depth = exp(-kCameraHeight/kScaleDepth);
                float cameraAngle = dot(-eyeRay,pos);
                float lightAngle = dot(_WorldSpaceLightPos0.xyz,pos);
                float cameraScale = scale(cameraAngle);
                float lightScale = scale(lightAngle);
                float cameraOffset = depth * cameraScale;
                float depthScale = lightScale + cameraScale;

                float sampleLength = far/kSamples;
                float scaledLength = sampleLength * kScale;
                float3 sampleRay = eyeRay * sampleLength;
                float3 samplePoint = cameraPos + sampleRay * 0.5;

                float3 frontColor = 0;
                float3 attenuate = 0;
                // for(int i=0;i<int(kSamples);i++)
                {
                    float height = length(samplePoint);
                    float depth = exp(kScaleOverScaleDepth * (kInnerRadius - height));
                    float scatter = depth * depthScale -cameraOffset;
                    scatter = clamp(scatter,0,kMAX_SCATTER);

                    attenuate = exp(-scatter * (kInvWavelength * kKr4PI + kKm4PI));
                    frontColor += attenuate * depth * scaledLength;
                    samplePoint += sampleRay;
                }
                cIn = frontColor * (kInvWavelength * kKrESun + kKmESun);
                cOut = clamp(attenuate,0,1);
            }
            /**
             calc eyeRay(worldPos) colors
            */
            void CalcColors(out half3 skyColor,out half3 groundColor,out half3 sunColor,float3 worldPos){
                float3 skyTintGamma = pow(_SkyTint,1/2.2);
                float3 scatterWaveLength = lerp(
                    kDefaultScatteringWavelength - kVariableRangeForScatteringWavelength, 
                    kDefaultScatteringWavelength + kVariableRangeForScatteringWavelength ,
                    1 - skyTintGamma
                    );
                float3 kInvWavelength = 1/pow(scatterWaveLength,4);

                float kKrESun = kRAYLEIGH * kSUN_BRIGHTNESS;
                float kKr4PI = kRAYLEIGH * 4.0 * 3.14159265;

                float3 cameraPos = float3(0,kInnerRadius + kCameraHeight,0);    // The camera's current position,(0,1.0001,0)
                float3 eyeRay = normalize(worldPos);

                float far = 0;
                half3 cIn=0,cOut=0;
                if(eyeRay.y >=0){
                    CalcSkyInOut(cIn/**/,cOut/**/,eyeRay,cameraPos,kInvWavelength,kKrESun,kKr4PI);
                }else{
                    CalcGroundInOut(cIn/**/,cOut/**/,eyeRay,cameraPos,kInvWavelength,kKrESun,kKr4PI);
                }
                groundColor = _Exposure * (cIn + _GroundColor * cOut);
                
                skyColor = _Exposure * cIn * getRayleighPhase(_WorldSpaceLightPos0.xyz,-eyeRay);
                
                half lightColorIntensity = clamp(length(_LightColor0),0.25,1);
                sunColor = kHDSundiskIntensityFactor * saturate(cOut) * _LightColor0.xyz / lightColorIntensity;
            }


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.pos = TransformObjectToHClip(v.vertex);

                // remove matrix translate
                o.worldPos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);

                CalcColors(o.skyColor,o.groundColor,o.sunColor,o.worldPos.xyz);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // CalcColors(i.skyColor,i.groundColor,i.sunColor,i.worldPos.xyz);
                half3 col = 0;
                float3 ray = normalize(i.worldPos);
                float3 lightDir = _WorldSpaceLightPos0;
                float y = ray.y/SKY_GROUND_THRESHOLD;

                col = lerp(i.groundColor,i.skyColor,saturate(y));

                col.xyz += ray.y > 0 ? 
                    i.sunColor * CalcSunAtten(lightDir,ray,_SunSizeRange) 
                    + CalcSunAtten(lightDir,-ray,_MoonSizeRange)
                    : 0;

                return half4(col,1);
            }
            ENDHLSL
        }
    }
}
