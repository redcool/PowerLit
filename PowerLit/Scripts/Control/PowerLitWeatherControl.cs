namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

#if UNITY_EDITOR
    using UnityEditor;

    [CustomEditor(typeof(PowerLitWeatherControl))]
    public class PowerLitWeatherControlEditor : PowerEditor<PowerLitWeatherControl>
    {
        public override string Version => "0.0.2";
        public override void OnInspectorGUI()
        {
            var inst = target as PowerLitWeatherControl;

            EditorGUILayout.BeginVertical("Box");
            EditorGUILayout.HelpBox("Use transform.forward control Global Wind Dir", MessageType.Info);
            EditorGUILayout.EndVertical();

            PowerLitWeatherControl control = (PowerLitWeatherControl)target;

            EditorGUI.BeginChangeCheck();
            DrawDefaultInspector();

            //================== instance manager
            if (GUILayout.Button("Use this"))
            {
                inst.enabled = false;
                inst.enabled = true;
            }

            if (!control.enabled)
                return;

            if (EditorGUI.EndChangeCheck() || control.transform.hasChanged)
            {
                control.UpdateParams();
            }


        }
    }
#endif

    /// <summary>
    /// update weather global params
    /// </summary>
    [ExecuteInEditMode]
    public class PowerLitWeatherControl : MonoBehaviour
    {
        public enum ThunderMode
        {
            Additive=0,Replace
        }
           
        public enum ScanLineAxis
        {
            X,Y,Z
        }

        public static MonoInstanceManager<PowerLitWeatherControl> instanceManager = new MonoInstanceManager<PowerLitWeatherControl>();

        [EditorGroupLayout("WeatherTex",true)]
        [Tooltip("noise texute used for Fog,Rain")]
        [LoadAsset("noise4layers.png")]
        public Texture2D _WeatherNoiseTexture;
        //[Header("Fog")]
        [EditorGroupLayout("Fog",true)]
        public bool _IsGlobalFogOn;
        [EditorGroupLayout("Fog")][Range(0,1)]public float _GlobalFogIntensity = 1;

        [EditorGroupLayout("Rain",true)]
        public bool _IsGlobalRainOn;
        [EditorGroupLayout("Rain")][Range(0, 1)] public float _GlobalRainIntensity = 1;

        [EditorGroupLayout("Snow",true)]
        public bool _IsGlobalSnowOn;
        [EditorGroupLayout("Snow")] [ColorUsage(true,true)] public Color _GlobalSnowColor = Color.white;
        [EditorGroupLayout("Snow")][Range(0,1)]public float _GlobalSnowIntensity = 1;

        [EditorGroupLayout("Wind",true)]
        public bool _IsGlobalWindOn;
        [EditorGroupLayout("Wind")][Range(0, 15)] public float _GlobalWindIntensity = 1;

        [EditorGroupLayout("Thunder",true)]
        public bool thunderOn;
        [EditorGroupLayout("Thunder")] public Light mainLight;
        [EditorGroupLayout("Thunder")] public ThunderMode thunderMode;
        [EditorGroupLayout("Thunder")] public AnimationCurve thunderCurve;
        [EditorGroupLayout("Thunder")] public Gradient thunderColor;
        [EditorGroupLayout("Thunder")][Min(0.1f)]public float thunderTime = 3;
        [EditorGroupLayout("Thunder")] public Vector2 thunderInvervalTime = new Vector2(1, 10);

        [EditorGroupLayout("Sky", true)] public bool isGlobalSkyOn;
        [EditorGroupLayout("Sky")][Range(0, 1)] public float skyExposure;
       

        //public PowerGradient TestThunderColor;
        float thunderStartTime;
        float mainLightStartIntensity;
        Color mainLightStartColor;

        [EditorGroupLayout("Particles follow camera",true)]
        public GameObject rainVFX;
        [EditorGroupLayout("Particles follow camera")] public GameObject snowVFX;

        [EditorGroupLayout("Particles follow camera")] public GameObject followTarget;
        [EditorGroupLayout("Particles follow camera")] public float followSpeed = 1;

        // world scanline
        //[EditorGroupLayout("World ScanLine", true)]
        //public bool showSceneBound=true;

        //[EditorGroupLayout("World ScanLine")]
        //[ColorUsage(false,true)]
        //public Color _EmissionScanLineColor = Color.white;
        //[Space(10)]
        //[EditorGroupLayout("World ScanLine")] public Transform sceneMinTr;
        //[EditorGroupLayout("World ScanLine")] public Vector3 _EmissionScanLineMin = Vector3.zero;
        //[EditorGroupLayout("World ScanLine")] public Transform sceneMaxTr;
        //[EditorGroupLayout("World ScanLine")] public Vector3 _EmissionScanLineMax = new Vector3(100,0,0);
        //[Space(10)]
        //[EditorGroupLayout("World ScanLine")][Range(0,1)] public float _EmissionScanLineRate = 0;
        //[EditorGroupLayout("World ScanLine")][Range(0,10)] public float _ScanLineRangeMin = 0.1f;
        //[EditorGroupLayout("World ScanLine")][Range(0,10)] public float _ScanLineRangeMax = 0.2f;
        //[EditorGroupLayout("World ScanLine")] public ScanLineAxis _ScanLineAxis;

        // clouds
        [EditorGroupLayout("Clouds", true)] public bool _CloudShadowOn;
        [EditorGroupLayout("Clouds")] public GameObject cloudShadowBox;
        [EditorGroupLayout("Clouds")] public Texture cloudShadowNoiseTex;

        [EditorGroupLayout("Clouds")] public Vector4 _CloudNoiseTilingOffset = new Vector4(.1f, .1f, 0, 0);
        [EditorGroupLayout("Clouds")] public bool _CloudNoiseOffsetStop;
        [EditorGroupLayout("Clouds")] [Range(0,1)] public float _CloudNoiseRangeMin = 0;
        [EditorGroupLayout("Clouds")] [Range(0,1)] public float _CloudNoiseRangeMax = 1;
        [EditorGroupLayout("Clouds")] public Color _CloudShadowColor = Color.black;
        [EditorGroupLayout("Clouds")] public float _CloudBaseShadowIntensity = 0;
        [EditorGroupLayout("Clouds")] public float _CloudShadowIntensity = 1;

        Material cloudShadowBoxMat;

        #region Shader Params
        int 
            _GlobalSkyExposure = Shader.PropertyToID(nameof(_GlobalSkyExposure)),
            _GlobalSkyOn = Shader.PropertyToID(nameof(_GlobalSkyOn)),
            _EmissionScanLineRange_Rate = Shader.PropertyToID(nameof(_EmissionScanLineRange_Rate)),
            _GlobalWindDir = Shader.PropertyToID(nameof(_GlobalWindDir))
            ;

        #endregion

        // Start is called before the first frame update
        public void Start()
        {
            InitWeather();
            instanceManager.Add(this);
        }

        private void OnDisable()
        {

            Shader.SetGlobalFloat(nameof(_IsGlobalFogOn), 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalRainOn), 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalSnowOn), 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalWindOn), 0);

            if (cloudShadowBox)
                cloudShadowBox.SetActive(false);
        }

        private void OnDestroy()
        {
            instanceManager.Remove(this);
            
        }

        private void Update()
        {
            UpdateThunder();

            UpdateVFX(rainVFX,_GlobalRainIntensity,_IsGlobalRainOn);
            UpdateVFX(snowVFX, _GlobalSnowIntensity,_IsGlobalSnowOn);

            UpdateParams();
        }

        public void InitWeather()
        {
            mainLightStartIntensity = mainLight ? mainLight.intensity : 0;
            mainLightStartColor = mainLight ? mainLight.color : Color.black;

            if (!followTarget)
                followTarget = Camera.main?.gameObject;

            UpdateVFX(rainVFX, _GlobalRainIntensity, _IsGlobalRainOn, true);
            UpdateVFX(snowVFX, _GlobalSnowIntensity, _IsGlobalSnowOn, true);
        }


        /// <summary>
        /// Set weather params
        /// </summary>
        public void UpdateParams()
        {
            Shader.SetGlobalFloat(nameof(_GlobalFogIntensity), _GlobalFogIntensity);
            Shader.SetGlobalFloat(nameof(_GlobalRainIntensity), _GlobalRainIntensity);
            Shader.SetGlobalFloat(nameof(_GlobalSnowIntensity), Mathf.SmoothStep(0, 1, _GlobalSnowIntensity));
            Shader.SetGlobalColor(nameof(_GlobalSnowColor), _GlobalSnowColor);

            var forward = transform.forward;
            Shader.SetGlobalVector(_GlobalWindDir, new Vector4(forward.x, forward.y, forward.z, _GlobalWindIntensity));

            Shader.SetGlobalFloat(nameof(_IsGlobalFogOn), _IsGlobalFogOn ? 1 : 0);

            Shader.SetGlobalTexture(nameof(_WeatherNoiseTexture), _WeatherNoiseTexture ?? Texture2D.whiteTexture);

            Shader.SetGlobalFloat(nameof(_IsGlobalRainOn), _IsGlobalRainOn ? 1 : 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalSnowOn), _IsGlobalSnowOn ? 1 : 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalWindOn), _IsGlobalWindOn ? 1 : 0);

            Shader.SetGlobalFloat(_GlobalSkyExposure, isGlobalSkyOn ? Mathf.Max(0.02f,skyExposure) : 1);

            // world scan line
            //Shader.SetGlobalVector(_EmissionScanLineRange_Rate, new Vector4(_ScanLineRangeMin*0.01f, _ScanLineRangeMax*0.01f, _EmissionScanLineRate));
            //Shader.SetGlobalVector(nameof(_EmissionScanLineMin), sceneMinTr ? sceneMinTr.position : _EmissionScanLineMin);
            //Shader.SetGlobalVector(nameof(_EmissionScanLineMax), sceneMaxTr ? sceneMaxTr.position : _EmissionScanLineMax);
            //Shader.SetGlobalColor(nameof(_EmissionScanLineColor), _EmissionScanLineColor);
            //Shader.SetGlobalInt(nameof(_ScanLineAxis), (int)_ScanLineAxis);

            UpdateCloudShadow();
        }

        GameObject GetCloudShadowBox()
        {
            SetupCloudShadowMat();

            var mainCam = Camera.main;
            if (!mainCam)
                return null;

            var box = GameObject.CreatePrimitive(PrimitiveType.Cube);
            box.transform.SetParent(mainCam.transform);
            box.transform.localPosition = Vector3.forward;
            box.name = "CloudShdowBox";
            box.GetComponent<MeshRenderer>().sharedMaterial = cloudShadowBoxMat;
            box.DestroyComponent<Collider>();
            return box;
        }

        void SetupCloudShadowMat()
        {
            if(!cloudShadowBoxMat)
                cloudShadowBoxMat = new Material(Shader.Find("FX/Others/BoxCloudShadow"));
        }

        private void UpdateCloudShadow()
        {
            if (_CloudShadowOn && !cloudShadowBox)
            {
                cloudShadowBox = GetCloudShadowBox();
            }
            if (cloudShadowBox)
                cloudShadowBox.SetActive(_CloudShadowOn);

            UpdateCloudShadowMat();

            void UpdateCloudShadowMat()
            {
                if (!cloudShadowBoxMat)
                    return;

                cloudShadowBoxMat.SetTexture("_NoiseTex", cloudShadowNoiseTex);
                cloudShadowBoxMat.SetVector("_NoiseTex_ST", _CloudNoiseTilingOffset);
                cloudShadowBoxMat.SetFloat("_NoiseTexOffsetStop", _CloudNoiseOffsetStop ? 1 : 0);
                cloudShadowBoxMat.SetFloat("_NoiseRangeMax", _CloudNoiseRangeMax);
                cloudShadowBoxMat.SetFloat("_NoiseRangeMin", _CloudNoiseRangeMin);
                cloudShadowBoxMat.SetColor("_ShadowColor", _CloudShadowColor);
                cloudShadowBoxMat.SetFloat("_BaseShadowIntensity", _CloudBaseShadowIntensity);
                cloudShadowBoxMat.SetFloat("_ShadowIntensity", _CloudShadowIntensity);
            }

            void UpdateCloudShadowGlobal()
            {
                Shader.SetGlobalFloat(nameof(_CloudShadowOn), _CloudShadowOn ? 1 : 0);
                Shader.SetGlobalVector(nameof(_CloudNoiseTilingOffset), _CloudNoiseTilingOffset);
                Shader.SetGlobalFloat(nameof(_CloudNoiseOffsetStop), _CloudNoiseOffsetStop ? 1 : 0);
                Shader.SetGlobalFloat(nameof(_CloudNoiseRangeMax), _CloudNoiseRangeMax);
                Shader.SetGlobalFloat(nameof(_CloudNoiseRangeMin), _CloudNoiseRangeMin);
                Shader.SetGlobalColor(nameof(_CloudShadowColor), _CloudShadowColor);
                Shader.SetGlobalFloat(nameof(_CloudBaseShadowIntensity), _CloudBaseShadowIntensity);
                Shader.SetGlobalFloat(nameof(_CloudShadowIntensity), _CloudShadowIntensity);
            }
        }

        void UpdateThunder()
        {
            if (!thunderOn || !mainLight)
                return;

            if (Time.time < thunderStartTime)
                return;

            var ntime = (Time.time - thunderStartTime) / thunderTime;
            var lightIntensity = thunderCurve.Evaluate(ntime);
            var lightColor = thunderColor.Evaluate(ntime);

            if (thunderMode == ThunderMode.Additive)
            {
                lightIntensity += mainLightStartIntensity;
                lightColor += mainLightStartColor;
            }

            mainLight.intensity = lightIntensity;
            mainLight.color = lightColor;

            if (ntime >=1)
            {
                thunderStartTime = Time.time + Random.Range(thunderInvervalTime.x, thunderInvervalTime.y);
            }
        }

        void UpdateVFX(GameObject particleGo,float intensity,bool isOn, bool isInstant=false)
        {
            if (!particleGo)
                return;

            ShowVFX(particleGo, intensity,isOn);
            VFXFollowCamera(particleGo,followTarget, isInstant);
        }

        private void VFXFollowCamera(GameObject particleGo, GameObject followTarget, bool isInstant=false)
        {
            if (!followTarget)
                return;
            var curPos = particleGo.transform.position;
            var targetPos = followTarget.transform.position;

            if (isInstant)
            {
                particleGo.transform.position = targetPos;
            }
            else
                particleGo.transform.position = Vector3.MoveTowards(curPos, targetPos, followSpeed * Time.deltaTime);
        }

        private static void ShowVFX(GameObject particleGo, float intensity,bool isOn)
        {
            if (intensity>0 && isOn && !particleGo.activeInHierarchy)
            {
                particleGo.SetActive(true);
            };
            if ((intensity<=0 || !isOn) && particleGo.activeInHierarchy)
            {
                particleGo.SetActive(false);
            }
        }

#if UNITY_EDITOR
        // Update is called once per frame

        private void OnDrawGizmos()
        { 
            Gizmos.color = Handles.zAxisColor;
            //Gizmos.DrawLine(transform.position, transform.position + transform.forward * 2);

            Handles.ArrowHandleCap(0,
                transform.position,
                transform.rotation * Quaternion.LookRotation(Vector3.forward),
                3, EventType.Repaint);

            //if(showSceneBound && sceneMaxTr && sceneMinTr)
            //{
            //    var maxPos = sceneMaxTr ? sceneMaxTr.position : _EmissionScanLineMax;
            //    var minPos = sceneMinTr ? sceneMinTr.position : _EmissionScanLineMin;

            //    var size = maxPos - minPos;
            //    var halfSize = size * 0.5f;
            //    Handles.DrawWireCube(minPos+ halfSize, size);
            //}
        }
#endif
    }

}