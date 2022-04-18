using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class HeightFogControl : MonoBehaviour
{
    [Header("HeightFog")]
    public float _HeightFogMin = 0;
    public float _HeightFogMax = 50;
    public Color _HeightFogMinColor, _HeightFogMaxColor;

    [Header("DepthFog")]
    public float _FogMin = 1;
    public float _FogMax = 100;
    public Color _FogNearColor,_FogFarColor;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalFloat(nameof(_HeightFogMin), _HeightFogMin);
        Shader.SetGlobalFloat(nameof(_HeightFogMax), _HeightFogMax);

        Shader.SetGlobalColor(nameof(_FogNearColor), _FogNearColor);
        //Shader.SetGlobalColor(nameof(_FogFarColor), _FogFarColor);
        Shader.SetGlobalColor(nameof(_HeightFogMinColor), _HeightFogMinColor);
        Shader.SetGlobalColor(nameof(_HeightFogMaxColor), _HeightFogMaxColor);

        Shader.SetGlobalVector("_FogDistance", new Vector4(_FogMin, _FogMax));

        RenderSettings.fogColor = _FogFarColor;
        RenderSettings.fogStartDistance = _FogMin;
        RenderSettings.fogEndDistance = _FogMax;
    }
}
