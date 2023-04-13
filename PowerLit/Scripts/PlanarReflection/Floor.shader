Shader "Unlit/Floor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _ControlMap("_ControlMap(R:blend [mainTex,reflectionTex])",2d) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        
        blend srcAlpha oneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 screenPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _ControlMap;
            float4 _ControlMap_ST;

            sampler2D _ReflectionTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                
                float4 sc = o.vertex;
                sc.x *=  -1;
                o.screenPos = ComputeScreenPos(sc);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 mainTex = tex2D(_MainTex,i.uv);
                float4 controlMap = tex2D(_ControlMap,TRANSFORM_TEX(i.uv,_ControlMap));

                float3 reflectionTex = tex2Dproj(_ReflectionTexture,i.screenPos);
                mainTex.xyz = lerp(mainTex.xyz,reflectionTex,controlMap.x);
                return mainTex;
            }
            ENDCG
        }
    }
}
