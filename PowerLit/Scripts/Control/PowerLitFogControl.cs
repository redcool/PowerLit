#if UNITY_EDITOR
using UnityEditor;
#endif
using PowerUtilities;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
using System.Runtime.InteropServices;

#if UNITY_EDITOR
[CustomEditor(typeof(PowerLitFogControl))]
public class PowerLitFogControlEditor : PowerEditor<PowerLitFogControl>
{
    public override bool NeedDrawDefaultUI() => true;

    public override string Version => "0.0.3";

    public override void DrawInspectorUI(PowerLitFogControl inst)
    {
        if(GUILayout.Button("Use this"))
        {
            inst.enabled = false;
            inst.enabled = true;
        }

    }

    public override void OnInspectorGUIChanged(PowerLitFogControl inst)
    {
        
    }
}
#endif

[ExecuteAlways]
public class PowerLitFogControl : MonoBehaviour
{
    [Min(1)] public float updateInterval = 1;
    float lastTime;

    [HelpBox]
    public string helpBox = "this block will saved to sphereFogDatas[0]";
    //================== default params ,keep
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

    //================== sphereFogDatas 
    public List<SphereFogData> sphereFogDatas = new List<SphereFogData>();
    // trace fog instances
    public static MonoInstanceManager<PowerLitFogControl> instanceManager = new MonoInstanceManager<PowerLitFogControl>();

    GraphicsBuffer fogBuffer;

    // Start is called before the first frame update
    void Start()
    {
        instanceManager.Add(this);
    }
    private void OnEnable()
    {
        UpdateParams();
    }

    [CompileFinished]
    static void OnCompileFinished()
    {
        instanceManager.InstanceList.ForEach(inst => inst.fogBuffer?.Dispose());
    }
    /// <summary>
    /// save default fogParams to sphereFogDatas[0]
    /// </summary>
    private void SyncDefaultParamsToDatas()
    {
        var fogData = sphereFogDatas.Count > 0 ? sphereFogDatas[0] : new SphereFogData();
        if (sphereFogDatas.Count == 0)
            sphereFogDatas.Add(fogData);

        fogData.isFogColorApplyAlpha = isFogColorApplyAlpha;
        fogData._HeightFogMin = _HeightFogMin;
        fogData._HeightFogMax = _HeightFogMax;
        fogData._HeightFogMinColor = _HeightFogMinColor;
        fogData._HeightFogMaxColor = _HeightFogMaxColor;
        fogData._HeightFogFilterUpFace = _HeightFogFilterUpFace;
        fogData._FogMin = _FogMin;
        fogData._FogMax = _FogMax;
        fogData._FogNearColor = _FogNearColor;
        fogData._FogFarColor = _FogFarColor;
        fogData._FogNoiseDir = _FogNoiseDir;

        fogData._FogNoiseStartRate = _FogNoiseStartRate;
        fogData._FogNoiseIntensity = _FogNoiseIntensity;
    }

    private void OnDestroy()
    {
        instanceManager.Remove(this);
        fogBuffer?.Dispose();
    }

    void LateUpdate()
    {
        SyncDefaultParamsToDatas();
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
    public void UpdateSphereFog(SphereFogData fogData)
    {
        if (fogData == null)
            return;

        Shader.SetGlobalFloat("_HeightFogMin", fogData._HeightFogMin);
        Shader.SetGlobalFloat("_HeightFogMax", fogData._HeightFogMax);
        Shader.SetGlobalInt("_HeightFogFilterUpFace", fogData._HeightFogFilterUpFace ? 1 : 0);

        Shader.SetGlobalColor("_FogNearColor", fogData._FogNearColor * (fogData.isFogColorApplyAlpha ? fogData._FogNearColor.a : 1));
        //Shader.SetGlobalColor("_FogFarColor", _FogFarColor);
        Shader.SetGlobalColor("_HeightFogMinColor", fogData._HeightFogMinColor * (fogData.isFogColorApplyAlpha ? fogData._HeightFogMinColor.a : 1));
        Shader.SetGlobalColor("_HeightFogMaxColor", fogData._HeightFogMaxColor * (fogData.isFogColorApplyAlpha ? fogData._HeightFogMaxColor.a : 1));

        Shader.SetGlobalVector("_FogDistance", new Vector4(fogData._FogMin, fogData._FogMax));
        Shader.SetGlobalVector("_FogNoiseTilingOffset", fogData._FogNoiseDir);
        Shader.SetGlobalVector("_FogNoiseParams", new Vector4(fogData._FogNoiseStartRate, fogData._FogNoiseIntensity));

        RenderSettings.fogColor = fogData._FogFarColor * (fogData.isFogColorApplyAlpha ? fogData._FogFarColor.a : 1);
        RenderSettings.fogStartDistance = fogData._FogMin;
        RenderSettings.fogEndDistance = fogData._FogMax;

        //RenderSettings.fog = _IsGlobalFogOn;
        Shader.SetGlobalVector("_FogParams", new Vector4(0, 0, -1 / (fogData._FogMax - fogData._FogMin), fogData._FogMax / (fogData._FogMax - fogData._FogMin)));
    }

    public void UpdateParams()
    {
        Shader.SetGlobalInt("_SphereFogLayers", sphereFogDatas.Count);

        // simpleFog
        UpdateSimpleFogParams(sphereFogDatas[0]);

        //========= strructedBuffer
        UpdateStructuredBuffer();
        //========= cbuffer
        UpdateCBuffer();
    }

    void UpdateSimpleFogParams(SphereFogData fogData)
    {
        Shader.SetGlobalVector("_FogParams", new Vector4(0, 0, -1 / (fogData._FogMax - fogData._FogMin), fogData._FogMax / (fogData._FogMax - fogData._FogMin)));
    }

    private void UpdateStructuredBuffer()
    {
        if (fogBuffer == null || fogBuffer.count != sphereFogDatas.Count)
        {
            fogBuffer?.Dispose();

            var stride = Marshal.SizeOf<SphereFogDataStruct>(); // 29 float
            fogBuffer = new GraphicsBuffer(GraphicsBuffer.Target.Structured, sphereFogDatas.Count, stride);
        }

        fogBuffer.SetData(sphereFogDatas
            .Select(d => (SphereFogDataStruct)d)
            .ToArray());
        Shader.SetGlobalBuffer("_SphereFogDatas", fogBuffer);
    }

    void UpdateCBuffer()
    {
        return;
        Shader.SetGlobalFloatArray("_HeightFogMinArray", sphereFogDatas.Select(d => d._HeightFogMin).ToArray());
        //_HeightFogMaxArray
        //    _HeightFogMinColorArray
        //    _HeightFogMaxColorArray

        //    _HeightFogFilterUpFaceArray
        //    _FogNearColorArrays
        //    _FogDistanceArray
        //    _FogNoiseTilingOffsetArray

        //    _FogNoiseParamsArray
    }
}
