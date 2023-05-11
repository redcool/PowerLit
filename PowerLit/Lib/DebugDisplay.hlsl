#if !defined(DEBUG_DISPLAY_HLSL)
#define DEBUG_DISPLAY_HLSL

#if defined(DEBUG_DISPLAY)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/DebuggingCommon.hlsl"

half3 CalcDebugColor(
    half3 albedo,
    half3 specular,
    half alpha,
    half metallic,
    half smoothness,
    half occlusion,
    half3 emission,
    half3 worldNormal,
    half3 tangentNormal
){
    switch(_DebugMaterialMode){
        case DEBUGMATERIALMODE_ALBEDO:
            return albedo;
        case DEBUGMATERIALMODE_SPECULAR:
            return specular;
        case DEBUGMATERIALMODE_ALPHA:
            return alpha;

        case DEBUGMATERIALMODE_METALLIC:
            return metallic;
        case DEBUGMATERIALMODE_SMOOTHNESS:
            return smoothness;
        case DEBUGMATERIALMODE_AMBIENT_OCCLUSION:
            return occlusion;

        case DEBUGMATERIALMODE_EMISSION:
            return emission;
        case DEBUGMATERIALMODE_NORMAL_WORLD_SPACE:
            return worldNormal*0.5+0.5;
        case DEBUGMATERIALMODE_NORMAL_TANGENT_SPACE:
            return tangentNormal*0.5+0.5;
    }
    return 0;
}

#endif //DEBUG_DISPLAY

void DebugColor(
    inout float4 mainColor,
    half3 albedo,
    half3 specular,
    half alpha,
    half metallic,
    half smoothness,
    half occlusion,
    half3 emission,
    half3 worldNormal,
    half3 tangentNormal
){
    #if defined(DEBUG_DISPLAY)
    mainColor.xyz = CalcDebugColor(
        albedo,
        specular,
        alpha,
        metallic,
        smoothness,
        occlusion,
        emission,
        worldNormal,
        tangentNormal
    );
    #endif
}

#endif //DEBUG_DISPLAY_HLSL