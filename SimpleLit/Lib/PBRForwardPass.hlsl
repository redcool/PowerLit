#if !defined(PBR_FORWARD_PASS_HLSL)
#define PBR_FORWARD_PASS_HLSL
#include "PBRInput.hlsl"
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/Lib/BSDF.hlsl"
#include "../../PowerShaderLib/Lib/Colors.hlsl"
#include "../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../PowerShaderLib/URPLib/Lighting.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1:TEXCOORD1;
    // float2 uv2:TEXCOORD2;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 uv : TEXCOORD0; // mainUV,lightmapUV
    float4 vertex : SV_POSITION;
    // TANGENT_SPACE_DECLARE(1,2,3);
    float4 tSpace0:TEXCOORD1;
    float4 tSpace1:TEXCOORD2;
    float4 tSpace2:TEXCOORD3;
    // float4 shadowCoord:TEXCOORD4;
    float4 fogCoord:TEXCOORD5;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f vert (appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);

    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
    o.uv.zw = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;

    TANGENT_SPACE_COMBINE(v.vertex,v.normal,v.tangent,o/**/);
    // o.shadowCoord = TransformWorldToShadowCoord(worldPos);
    o.fogCoord.xy = CalcFogFactor(p.xyz);


    return o;
}

float4 frag (v2f i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);

    TANGENT_SPACE_SPLIT(i);

    float2 mainUV = i.uv.xy;
    float2 lightmapUV = i.uv.zw;

    float4 pbrMask = tex2D(_PbrMask,mainUV);
    float metallic = 0;
    float smoothness =0;
    float occlusion =0;
    SplitPbrMaskTexture(metallic/**/,smoothness/**/,occlusion/**/,pbrMask,int3(0,1,2),float3(_Metallic,_Smoothness,_Occlusion),false);

    float roughness = 0;
    float a = 0;
    float a2 = 0;
    CalcRoughness(roughness/**/,a/**/,a2/**/,smoothness);

    float3 tn = UnpackNormalScale(tex2D(_NormalMap,mainUV),_NormalScale);
    float3 n = normalize(TangentToWorld(tn,i.tSpace0,i.tSpace1,i.tSpace2));

    float3 l = (_MainLightPosition.xyz);
    float3 v = normalize(UnityWorldSpaceViewDir(worldPos));
    float3 h = normalize(l+v);
    
    float lh = saturate(dot(l,h));
    float nh = saturate(dot(n,h));
    float nl = saturate(dot(n,l));

    float nv = saturate(dot(n,v));
// return v.xyzx;

    float4 shadowMask = SampleShadowMask(i.uv.zw);
    // return shadowMask;
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    float shadowAtten = CalcShadow(shadowCoord,worldPos,shadowMask,_MainLightShadowSoftScale);
    float3 radiance = _MainLightColor.xyz * nl * shadowAtten;

//--------- lighting
    float4 mainTex = tex2D(_MainTex, mainUV) * _Color;
    float3 albedo = mainTex.xyz;
    float alpha = mainTex.w;

    #if defined(ALPHA_TEST)
        clip(alpha - _Cutoff);
    #endif
    
    float specTerm = 0;

    if(_SpecularOn){
        // if(_PbrMode == 0){
        #if defined(_PBRMODE_PBR)
            specTerm = MinimalistCookTorrance(nh,lh,a,a2);
            // specTerm = D_GGXNoPI(nh,a2);
        // }else if(_PbrMode == 1){
        #elif defined(_PBRMODE_ANISO)
            float3 t = tangent;//(cross(n,float3(0,1,0)));
            float3 b = binormal;//cross(t,n);
            if(_CalcTangent){
                t = cross(n,float3(0,1,0));
                b = cross(t,n);
            }
            b += n * _AnisoShift;
            
            float th = dot(t,h);
            float bh = dot(b,h);
            float anisoRough = _AnisoRough + 0.5;
            specTerm = D_GGXAnisoNoPI(th,bh,nh,anisoRough,1 - anisoRough);
        #elif defined(_PBRMODE_CHARLIE)
        // }else if(_PbrMode == 2){
            specTerm = CharlieD(nh, roughness);
        // }
        #endif
        // will show strange color, exceed range
        specTerm = min(100,specTerm);
    }

    float3 specColor = lerp(0.04,albedo,metallic);

    // if(_TFOn)
    // {
    //     float3 thinFilm = ThinFilm(1- nv,_TFScale,_TFOffset,_TFSaturate,_TFBrightness);
    //     specColor = (specColor+1) * thinFilm;
    // }
    
    float3 diffColor = albedo.xyz * (1- metallic);
    float3 directColor = (diffColor + specColor * specTerm) * radiance;
// return directColor.xyzx;
//------- gi
    float3 giColor = 0;
    float3 giDiff = CalcGIDiff(normal,diffColor,lightmapUV);
    float3 giSpec = CalcGISpec(unity_SpecCube0,samplerunity_SpecCube0,unity_SpecCube0_HDR,specColor,worldPos,n,v,0/*reflectDirOffset*/,1/*reflectIntensity*/,nv,roughness,a2,smoothness,metallic);
    giColor = (giDiff + giSpec) * occlusion;
// return giColor.xyzx;

    float4 col = 0;
    col.rgb = directColor + giColor;

    #if defined(_ADDITIONAL_LIGHTS_ON)
        col.rgb += CalcAdditionalLights(worldPos,diffColor,specColor,n,v,a,a2,shadowMask);
    #endif
//------ emission
    #if defined(_EMISSION)
        col.rgb += CalcEmission(tex2D(_EmissionMap,mainUV),_EmissionColor.xyz,_EmissionColor.w);
    #endif
//------ fog
    // col.rgb = MixFog(col.xyz,i.fogFactor.x);
    BlendFogSphereKeyword(col.rgb/**/,worldPos,i.fogCoord.xy,_HeightFogOn,_FogNoiseOn,_DepthFogOn); // 2fps
    col.a = alpha;
    return col;
}

#endif //PBR_FORWARD_PASS_HLSL