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

    public Vector4 FogParams() => new Vector4(0, 0, -1 / (_FogMax - _FogMin), _FogMax / (_FogMax - _FogMin));
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
            heightFogMin = fogData._HeightFogMin,
            heightFogMax = fogData._HeightFogMax,
            heightFogFilterUpFace = fogData._HeightFogFilterUpFace ? 1 : 0,

            fogNearColor = fogData._FogNearColor * (fogData.isFogColorApplyAlpha ? fogData._FogNearColor.a : 1),
            fogFarColor = fogData._FogFarColor * (fogData.isFogColorApplyAlpha ? fogData._FogFarColor.a : 1),

            heightFogMinColor = fogData._HeightFogMinColor * (fogData.isFogColorApplyAlpha ? fogData._HeightFogMinColor.a : 1),
            heightFogMaxColor = fogData._HeightFogMaxColor * (fogData.isFogColorApplyAlpha ? fogData._HeightFogMaxColor.a : 1),

            fogDistance = new Vector4(fogData._FogMin, fogData._FogMax),
            fogNoiseTilingOffset = fogData._FogNoiseDir,
            fogNoiseParams = new Vector4(fogData._FogNoiseStartRate, fogData._FogNoiseIntensity),
            fogParams = fogData.FogParams(),
        };
    }
};