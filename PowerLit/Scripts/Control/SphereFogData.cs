using PowerUtilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

/// <summary>
/// Show in inspector
/// </summary>
[Serializable]
public class SphereFogData
{
    [Tooltip("fogColor.rgb multiply fogColor.a")]
    public bool isFogColorApplyAlpha;

    [Header("HeightFog")]
    public float _HeightFogMin = 0;
    public float _HeightFogMax = 50;
    public Color _HeightFogMinColor = new Color(.5f, .5f, .5f, 1), _HeightFogMaxColor = Color.white;
    public bool _HeightFogFilterUpFace;

    [Header("DepthFog")]
    public float _FogMin = 1;
    public float _FogMax = 100;
    public Color _FogNearColor = Color.black, _FogFarColor = Color.white;

    [Header("Fog Noise")]
    [DisplayName("FogNoise TilingOffset", "xy : worldPos tiling , zw:worldPos offset")]
    //[ListItemDraw("x:,x,y:,y,z:,z,w:,w", "15,80,15,80,15,80,15,80",isShowTitleRow =true)]
    public Vector4 _FogNoiseDir = new Vector4(0.4f, .3f, .2f, .1f);

    [Tooltip("noise appear out of this")]
    [Range(0.02f, 0.99f)] public float _FogNoiseStartRate = 0.1f;

    [Range(0, 1)] public float _FogNoiseIntensity = 1;

    //============ shortcuts 
    public Vector4 FogParams() => new Vector4(0, 0, -1 / (_FogMax - _FogMin), _FogMax / (_FogMax - _FogMin));
    public float HeightFogMin() => _HeightFogMin;
    public float HeightFogMax() => _HeightFogMax;
    public float HeightFogFilterUpFace() => _HeightFogFilterUpFace ? 1 : 0;

    public Vector4 FogNearColor() => _FogNearColor * (isFogColorApplyAlpha ? _FogNearColor.a : 1);
    public Vector4 FogFarColor() => _FogFarColor * (isFogColorApplyAlpha ? _FogFarColor.a : 1);

    public Vector4 HeightFogMinColor() => _HeightFogMinColor * (isFogColorApplyAlpha ? _HeightFogMinColor.a : 1);
    public Vector4 HeightFogMaxColor() => _HeightFogMaxColor * (isFogColorApplyAlpha ? _HeightFogMaxColor.a : 1);

    public Vector4 FogDistance() => new Vector4(_FogMin, _FogMax);
    public Vector4 FogNoiseTilingOffset() => _FogNoiseDir;
    public Vector4 FogNoiseParams() => new Vector4(_FogNoiseStartRate, _FogNoiseIntensity);
}
/// <summary>
/// Sync PowerShaderLib/SphereSogLib
/// </summary>
public struct SphereFogDataStruct
{
    public float heightFogMin;
    public float heightFogMax;
    public Vector4 heightFogMinColor;
    public Vector4 heightFogMaxColor;
    public float heightFogFilterUpFace;

    public Vector4 fogNearColor;
    public Vector4 fogFarColor;
    public Vector2 fogDistance;
    public Vector4 fogNoiseTilingOffset;
    public Vector4 fogNoiseParams; // composite args
    public Vector4 fogParams; // for SIMPLE_FOG

    public static implicit operator SphereFogDataStruct(SphereFogData fogData)
    {
        return new SphereFogDataStruct
        {
            heightFogMin = fogData.HeightFogMin(),
            heightFogMax = fogData.HeightFogMax(),
            heightFogFilterUpFace = fogData.HeightFogFilterUpFace(),

            fogNearColor = fogData.FogNearColor(),
            fogFarColor = fogData.FogFarColor(),

            heightFogMinColor = fogData.HeightFogMinColor(),
            heightFogMaxColor = fogData.HeightFogMaxColor(),

            fogDistance = fogData.FogDistance(),
            fogNoiseTilingOffset = fogData.FogNoiseTilingOffset(),
            fogNoiseParams = fogData.FogNoiseParams(),
            fogParams = fogData.FogParams(),
        };
    }
};

public static class SphereFogDataSplitter
{
    public static List<float> heightFogMin = new List<float>();
    public static List<float> heightFogMax = new List<float>();
    public static List<Vector4> heightFogMinColor = new List<Vector4>();
    public static List<Vector4> heightFogMaxColor = new List<Vector4>();
    public static List<float> heightFogFilterUpFace = new List<float>();

    public static List<Vector4> fogNearColor = new List<Vector4>();
    public static List<Vector4> fogFarColor = new List<Vector4>();
    public static List<Vector4> fogDistance = new List<Vector4>();
    public static List<Vector4> fogNoiseTilingOffset = new List<Vector4>();
    public static List<Vector4> fogNoiseParams = new List<Vector4>();
    public static List<Vector4> fogParams = new List<Vector4>();

    public static void Split(List<SphereFogData> fogDatas)
    {
        ClearAll();
        foreach (var fogData in fogDatas)
        {
            heightFogMin.Add(fogData.HeightFogMin());
            heightFogMax.Add(fogData.HeightFogMax());
            heightFogFilterUpFace.Add(fogData.HeightFogFilterUpFace());

            fogNearColor.Add(fogData.FogNearColor());
            fogFarColor.Add(fogData.FogFarColor());

            heightFogMinColor.Add(fogData.HeightFogMinColor());
            heightFogMaxColor.Add(fogData.HeightFogMaxColor());

            fogDistance.Add(fogData.FogDistance());
            fogNoiseTilingOffset.Add(fogData.FogNoiseTilingOffset());
            fogNoiseParams.Add(fogData.FogNoiseParams());
            fogParams.Add(fogData.FogParams());

        }
    }

    private static void ClearAll()
    {
        heightFogMin.Clear();
        heightFogMax.Clear();
        heightFogMinColor.Clear();
        heightFogMaxColor.Clear();
        heightFogFilterUpFace.Clear();

        fogNearColor.Clear();
        fogFarColor.Clear();
        fogDistance.Clear();
        fogNoiseTilingOffset.Clear();
        fogNoiseParams.Clear();
        fogParams.Clear();
    }

    public static void UpdateParams(List<SphereFogData> sphereFogDatas)
    {
        Split(sphereFogDatas);

        Shader.SetGlobalFloatArray("_HeightFogMinArray", heightFogMin);
        Shader.SetGlobalFloatArray("_HeightFogMaxArray", heightFogMax);
        Shader.SetGlobalVectorArray("_HeightFogMinColorArray", heightFogMinColor);
        Shader.SetGlobalVectorArray("_HeightFogMaxColorArray", heightFogMaxColor);
        Shader.SetGlobalFloatArray("_HeightFogFilterUpFaceArray", heightFogFilterUpFace);

        Shader.SetGlobalVectorArray("_FogNearColorArrays", fogNearColor);
        Shader.SetGlobalVectorArray("_FogFarColorArrays", fogFarColor);
        Shader.SetGlobalVectorArray("_FogDistanceArray", fogDistance);
        Shader.SetGlobalVectorArray("_FogNoiseTilingOffsetArray", fogNoiseTilingOffset);
        Shader.SetGlobalVectorArray("_FogNoiseParamsArray", fogNoiseParams);
        Shader.SetGlobalVectorArray("_FogParamsArray", fogParams);
    }
}