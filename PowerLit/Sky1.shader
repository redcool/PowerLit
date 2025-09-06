Shader "Skybox/Sky1"
{
    Properties
    {
    [Group(Main)]
    // [GroupEnum(Main,_SUNDISK_NONE _SUNDISK_SIMPLE _SUNDISK_HIGH_QUALITY ,true)] _SunDisk ("Sun", Int) = 2
    [GroupItem(Main)]_SunSize ("Sun Size", Range(0,1)) = 0.04
    [GroupItem(Main)]_SunSizeConvergence("Sun Size Convergence", Range(1,10)) = 5

    [GroupItem(Main)]_AtmosphereThickness ("Atmosphere Thickness", Range(0,5)) = 1.0
    [GroupItem(Main)]_SkyTint ("Sky Tint", Color) = (.5, .5, .5, 1)
    [GroupItem(Main)]_GroundColor ("Ground", Color) = (.369, .349, .341, 1)

    [GroupItem(Main)]_Exposure("Exposure", Range(0, 8)) = 1.3

    [GroupItem(Main)]_Test("_Test", float) = 1.3
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
                half _SunSize;
                half _SunSizeConvergence;
                half3 _SkyTint;
                half _AtmosphereThickness;
                half _Test;
            CBUFFER_END

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
        static const float kOuterRadius2 = OUTER_RADIUS*OUTER_RADIUS;
        /**
            地球,半径比例
        */
        static const float kInnerRadius = 1.0;
        static const float kInnerRadius2 = 1.0;

        static const float kCameraHeight = 0.0001;

        // #define kRAYLEIGH (lerp(0.0, 0.0025, pow(_AtmosphereThickness,2.5)))      // Rayleigh constant
        #define kRAYLEIGH (0.0025 * pow(_AtmosphereThickness,2.5))      // Rayleigh constant
        #define kMIE 0.0010             // Mie constant
        #define kSUN_BRIGHTNESS 20.0    // Sun brightness

        #define kMAX_SCATTER 50.0 // Maximum scattering value, to prevent math overflows on Adrenos

        static const half kHDSundiskIntensityFactor = 15.0;
        // static const half kSimpleSundiskIntensityFactor = 27.0;

        static const half kSunScale = 400.0 * kSUN_BRIGHTNESS;
        static const float kKmESun = kMIE * kSUN_BRIGHTNESS;
        static const float kKm4PI = kMIE * 4.0 * 3.14159265;
        static const float kScale = 1.0 / (OUTER_RADIUS - 1.0); // 1/0.025
        static const float kScaleDepth = 0.25;
        static const float kScaleOverScaleDepth = (1.0 / (OUTER_RADIUS - 1.0)) / 0.25;// 4/0.025
        static const float kSamples = 2.0; // THIS IS UNROLLED MANUALLY, DON'T TOUCH

        /** 
            MIE_G : 米氏(大颗粒)散射的各向异性参数（Anisotropy Factor）,
            值域[-1,1],  
                -1 : 向后散射, 
                0 : 均匀散射
                1 : 向前散射

            MIE_G2 常用于亨耶-格林斯坦相位函数（Henyey-Greenstein Phase Function）: hgPhase
        */
        #define MIE_G (-0.990)
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
            half temp = 1.0 + MIE_G2 - 2.0 * MIE_G * eyeCos;
            temp = pow(temp, pow(sunSize,0.65) * 10);
            temp = max(temp,1.0e-4); // prevent division by zero, esp. in half precision
            temp = 1.5 * ((1.0 - MIE_G2) / (2.0 + MIE_G2)) * (1.0 + eyeCos2) / temp;
            // temp = (1-MIE_G2)/temp*0.6;

            return temp;
        }
        // Calc HG phase
        float HenyeyGreenstein(float g, float cosTheta/* dot(lightDir,viewDir)*/) {
            float g2 = g * g;
            float numerator = 1.0 - g2;
            float denominator = 1.0 + g2 - 2.0 * g * cosTheta;
            return numerator / pow(denominator, 1.5);
            // return numerator / pow(denominator, 1.5)/PI_4;
        }

        float calcSunAttenuation(float3 lightDir,float3 ray){
            float focusedEyeCos = pow(saturate(dot(lightDir,ray)),_SunSizeConvergence);
            return getMiePhase(-focusedEyeCos,focusedEyeCos * focusedEyeCos,_SunSize);
        }
                
        float scale(float inCos)
        {
            float x = 1.0 - inCos;
            return 0.25 * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
        }
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


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.pos = TransformObjectToHClip(v.vertex);

                float3 skyTintGamma = pow(_SkyTint,1/2.2);
                float3 scatterWaveLength = lerp(
                    kDefaultScatteringWavelength - kVariableRangeForScatteringWavelength * _Test, 
                    kDefaultScatteringWavelength + kVariableRangeForScatteringWavelength *_Test ,
                    1 - skyTintGamma
                    );
                float3 kInvWavelength = 1/pow(scatterWaveLength,4);

                float kKrESun = kRAYLEIGH * kSUN_BRIGHTNESS;
                float kKr4PI = kRAYLEIGH * 4.0 * 3.14159265;

                float3 cameraPos = float3(0,kInnerRadius + kCameraHeight,0);    // The camera's current position
                o.worldPos = TransformObjectToWorld(v.vertex);
                // float3 eyeRay = normalize(mul((float3x3)unity_ObjectToWorld,v.vertex.xyz));
                float3 eyeRay = normalize(o.worldPos.xyz);

                float far = 0;
                half3 cIn,cOut;
                if(eyeRay.y >=0){
                    // sky
                    // Calculate the length of the "atmosphere"
                    far = sqrt(kOuterRadius2+kInnerRadius2*eyeRay.y*eyeRay.y-kInnerRadius2) - kInnerRadius * eyeRay.y;
                    // far = 0.1;

                    float pos = cameraPos + far * eyeRay;

                    float height = kInnerRadius + kCameraHeight;
                    float depth = exp(kScaleOverScaleDepth * -kCameraHeight);
                    float startAngle = dot(eyeRay,cameraPos)/height;
                    float startOffset = depth * scale(startAngle);

                    float sampleLength = far/kSamples;
                    float scaledLength = sampleLength * kScale;
                    float3 sampleRay = eyeRay * sampleLength;
                    float3 samplePoint = cameraPos + sampleRay * 0.5;

                    float3 frontColor = 0;
                    // [unroll(2)]
                    // for(int i=0;i<(int)kSamples;i++)
                    {
                        float height = length(samplePoint);
                        float depth = exp(kScaleOverScaleDepth * (kInnerRadius - height));
                        float lightAngle = dot(_WorldSpaceLightPos0.xyz,samplePoint)/height;
                        float cameraAngle = dot(eyeRay,samplePoint)/height;
                        float scatter = (startOffset + depth*scale(lightAngle) - scale(cameraAngle));
                        float3 attenuate = exp(- clamp(scatter,0,kMAX_SCATTER) * (kInvWavelength * kKr4PI + kKr4PI));

                        frontColor += attenuate * depth * scaledLength;
                        samplePoint += sampleRay;
                    }
                    cIn = frontColor * kInvWavelength * kKrESun;
                    cOut = frontColor * kKmESun;
                }else{
                    //ground
                    far = -kCameraHeight/min(-0.001,eyeRay.y);
                    float3 pos = cameraPos + far * eyeRay;

                    float depth = exp(-kCameraHeight) * (1/kScaleDepth);
                    float cameraAngle = dot(-eyeRay,pos);
                    float lightAngle = dot(_WorldSpaceLightPos0.xyz,pos);
                    float cameraScale = scale(cameraAngle);
                    float lightScale = scale(lightAngle);
                    float cameraOffset = depth * cameraScale;
                    float temp = lightScale + cameraScale;

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
                        float scatter = depth * temp -cameraOffset;
                        attenuate = exp(- clamp(scatter,0,kMAX_SCATTER) * (kInvWavelength*kKr4PI+kKm4PI));
                        frontColor += attenuate * depth * scaledLength;
                        samplePoint += sampleRay;
                    }
                    cIn = frontColor * (kInvWavelength * kKrESun + kKmESun);
                    cOut = clamp(attenuate,0,1);
                }

                o.groundColor = _Exposure * (cIn + _GroundColor * cOut);
                o.skyColor = _Exposure * (cIn * getRayleighPhase(_WorldSpaceLightPos0.xyz,-eyeRay));

                half lightColorIntensity = clamp(length(_LightColor0),0.25,1);
                o.sunColor = kHDSundiskIntensityFactor * saturate(cOut) * _LightColor0.xyz / lightColorIntensity;

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 col = 0;
                float3 ray = normalize(-i.worldPos);
                float3 lightDir = _WorldSpaceLightPos0;
                float lr = dot(lightDir,ray);
                float lrPow = pow(saturate(lr),_SunSizeConvergence);
                // return HenyeyGreenstein(_Test,lr);
                // return calcSunAttenuation(lightDir,-ray);
                // return getMiePhase(lr,lr*lr,_SunSize) * _SkyTint.xyzx;

                float y = ray.y/SKY_GROUND_THRESHOLD;
                col = lerp(i.skyColor,i.groundColor,saturate(y));
                col += ray.y <0? i.sunColor * calcSunAttenuation(lightDir,-ray) : 0;

                return half4(col,1);
            }
            ENDHLSL
        }
    }
}
