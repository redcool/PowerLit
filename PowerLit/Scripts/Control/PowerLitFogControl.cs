#if UNITY_EDITOR
using UnityEditor;
#endif
using PowerUtilities;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

#if UNITY_EDITOR
[CustomEditor(typeof(PowerLitFogControl))]
public class PowerLitFogControlEditor : PowerEditor<PowerLitFogControl>
{
    public override bool NeedDrawDefaultUI() => true;

    public override string Version => "0.0.2";

    public override void DrawInspectorUI(PowerLitFogControl inst)
    {
        if(GUILayout.Button("Use this"))
        {
            inst.enabled = false;
            inst.enabled = true;
        }
    }
}
#endif

[ExecuteAlways]
public class PowerLitFogControl : MonoBehaviour
{
    [Min(1)] public float updateInterval = 1;
    float lastTime;

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
    public Vector4 _FogNoiseDir = new Vector4(0.4f, .3f, .2f,.1f);

    [HideInInspector] [Obsolete]
    [Range(0, 1)] public float _FogNoiseTiling = .1f;

    [Tooltip("noise appear out of this")]
    [Range(0.02f, 0.99f)] public float _FogNoiseStartRate = 0.1f;


    [Range(0, 1)] public float _FogNoiseIntensity = 1;

    // trace fog instances
    public static MonoInstanceManager<PowerLitFogControl> instanceManager = new MonoInstanceManager<PowerLitFogControl>();

    // Start is called before the first frame update
    void Start()
    {
        instanceManager.Add(this);
    }
    private void OnEnable()
    {
        UpdateParams();
        
    }
    private void OnDestroy()
    {
        instanceManager.Remove(this);
    }

    void LateUpdate()
    {
        TryUpdateParams();
    }

    public void TryUpdateParams()
    {
#if UNITY_EDITOR
        UpdateParams();
#else
        if(Time.time - lastTime> updateInterval)
        {
            lastTime = Time.time;
            UpdateParams();
        }
#endif
    }

    // Update is called once per frame
    public void UpdateParams()
    {
        Shader.SetGlobalFloat(nameof(_HeightFogMin), _HeightFogMin);
        Shader.SetGlobalFloat(nameof(_HeightFogMax), _HeightFogMax);
        Shader.SetGlobalInt(nameof(_HeightFogFilterUpFace), _HeightFogFilterUpFace ? 1 : 0);

        Shader.SetGlobalColor(nameof(_FogNearColor), _FogNearColor* (isFogColorApplyAlpha ? _FogNearColor.a : 1));
        //Shader.SetGlobalColor(nameof(_FogFarColor), _FogFarColor);
        Shader.SetGlobalColor(nameof(_HeightFogMinColor), _HeightFogMinColor* (isFogColorApplyAlpha ? _HeightFogMinColor.a : 1));
        Shader.SetGlobalColor(nameof(_HeightFogMaxColor), _HeightFogMaxColor* (isFogColorApplyAlpha ? _HeightFogMaxColor.a : 1));

        Shader.SetGlobalVector("_FogDistance", new Vector4(_FogMin, _FogMax));
        Shader.SetGlobalVector("_FogNoiseTilingOffset", _FogNoiseDir);
        Shader.SetGlobalVector("_FogNoiseParams", new Vector4(_FogNoiseStartRate, _FogNoiseIntensity));

        RenderSettings.fogColor = _FogFarColor * (isFogColorApplyAlpha ? _FogFarColor.a : 1);
        RenderSettings.fogStartDistance = _FogMin;
        RenderSettings.fogEndDistance = _FogMax;

        //RenderSettings.fog = _IsGlobalFogOn;
        Shader.SetGlobalVector("_FogParams", new Vector4(0, 0, -1 / (_FogMax - _FogMin), _FogMax / (_FogMax - _FogMin)));
    }
}
