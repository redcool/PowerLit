#if !defined(DEBUG_DISPLAY_HLSL)
#define DEBUG_DISPLAY_HLSL

#if defined(DEBUG_DISPLAY)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/DebuggingCommon.hlsl"

half3 CalculateDebugLightingComplexityColor(float2 screenUV, half3 albedo)
{
    // Assume a main light and add 1 to the additional lights.
    int numLights = GetAdditionalLightsCount() + 1;

    const uint2 tileSize = uint2(32,32);
    const uint maxLights = 9;
    const float opacity = 0.8f;

    uint2 pixelCoord = uint2(screenUV * _ScreenParams.xy);
    half3 base = albedo;
    half4 overlay = half4(OverlayHeatMap(pixelCoord, tileSize, numLights, maxLights, opacity));

    uint2 tileCoord = (float2)pixelCoord / tileSize;
    uint2 offsetInTile = pixelCoord - tileCoord * tileSize;
    bool border = any(offsetInTile == 0 || offsetInTile == tileSize.x - 1);
    if (border)
        overlay = half4(1, 1, 1, 0.4f);

    return lerp(base.rgb, overlay.rgb, overlay.a);
}

half3 CalcDebugColor(
    half3 albedo,
    half3 specular,
    half alpha,
    half metallic,
    half smoothness,
    half occlusion,
    half3 emission,
    half3 worldNormal,
    half3 tangentNormal,
    half2 screenUV
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
        case DEBUGMATERIALMODE_LIGHTING_COMPLEXITY:
            return CalculateDebugLightingComplexityColor(screenUV,albedo);
    }
    return 0;
}

half3 CalcValidateColor(){

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
    half3 tangentNormal,
    half2 screenUV
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
        tangentNormal,
        screenUV
    );
    #endif
}

#endif //DEBUG_DISPLAY_HLSL