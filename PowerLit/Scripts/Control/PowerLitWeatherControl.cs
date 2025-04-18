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
        public override string Version => "0.0.3";
        public override string TitleHelpStr => "Use transform.forward control Global Wind Dir";
        public override bool NeedDrawDefaultUI() => true;

        public override void DrawInspectorUI(PowerLitWeatherControl inst)
        {
            DrawOptions(inst);
        }

        static void DrawOptions(PowerLitWeatherControl inst)
        {
            EditorGUI.BeginChangeCheck();

            GUILayout.BeginVertical(EditorStylesEx.HelpBox);
            GUILayout.Label("Options", EditorStyles.boldLabel);
            if (GUILayout.Button("Use this"))
            {
                inst.enabled = false;
                inst.enabled = true;
            }
            GUILayout.EndVertical();

            if (!inst.enabled)
                return;

            if (EditorGUI.EndChangeCheck() || inst.transform.hasChanged)
            {
                inst.UpdateParams();
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
        // 
        public const string 
            SCENE_TEXS = "SceneTexs",
            RAIN = "Rain",
            SNOW = "Snow",
            WIND ="Wind",
            THUNDER = "Thunder",
            FOG="Fog",
            SKY = "Sky",
            PARTICLES_FLOW_CAMERA="ParticlesFlowCamera",
            CLOUD_SHADOW="CloudShadow"
            ;
        public enum ThunderMode
        {
            Additive=0,Replace
        }

        public static MonoInstanceManager<PowerLitWeatherControl> instanceManager = new MonoInstanceManager<PowerLitWeatherControl>();
        /// <summary>
        /// override settings
        /// </summary>
        //[EditorGroup("Override Settings",true)]
        //[Tooltip("use this setting override PowerLitWeatherControl's params")]
        //[EditorSettingSO]
        //public PowerLitWeatherSettings overrideWeatherSettings;

        /// <summary>
        /// current settings
        /// </summary>
        //--------SceneTex
        [EditorGroup(SCENE_TEXS, true)]
        [Tooltip("noise texute used for Fog,Rain")]
        [LoadAsset("noise4layers.png")]
        public Texture2D _WeatherNoiseTexture;

        [EditorGroup(SCENE_TEXS)]
        [Tooltip("Scene MatCap ,used for MIN_VERSION ")]
        public Texture2D _SceneMatCap;

        [EditorGroup(SCENE_TEXS)]
        [Tooltip("SceneMatCap(xy:Tiling,zw:Offset)")]
        public Vector4 _SceneMatCap_ST = new Vector4(1, 1, 0, 0);

        //[Header("Fog")]
        [EditorGroup(FOG,true)]
        public bool _IsGlobalFogOn;
        [EditorGroup(FOG)][Range(0,1)]public float _GlobalFogIntensity = 1;

        [EditorGroup(RAIN,true)]
        public bool _IsGlobalRainOn;
        [EditorGroup(RAIN)][Range(0, 1)] public float _GlobalRainIntensity = 1;

        [EditorGroup(SNOW,true)]
        public bool _IsGlobalSnowOn;
        [EditorGroup(SNOW)] [ColorUsage(true,true)] public Color _GlobalSnowColor = Color.white;
        [EditorGroup(SNOW)][Range(0,1)]public float _GlobalSnowIntensity = 1;

        [EditorGroup(WIND,true)]
        public bool _IsGlobalWindOn;
        [EditorGroup(WIND)][Range(0, 15)] public float _GlobalWindIntensity = 1;

        [EditorGroup(THUNDER,true)]
        public bool thunderOn;
        [EditorGroup(THUNDER)] public Light mainLight;
        [EditorGroup(THUNDER)] public ThunderMode thunderMode;
        [EditorGroup(THUNDER)] public AnimationCurve thunderCurve;
        [EditorGroup(THUNDER)] public Gradient thunderColor;
        [EditorGroup(THUNDER)][Min(0.1f)]public float thunderTime = 3;
        [EditorGroup(THUNDER)] public Vector2 thunderInvervalTime = new Vector2(1, 10);

        [EditorGroup(SKY, true)] public bool isGlobalSkyOn;
        [EditorGroup(SKY)][Range(0, 1)] public float skyExposure;
       

        //public PowerGradient TestThunderColor;
        float thunderStartTime;
        float mainLightStartIntensity;
        Color mainLightStartColor;

        [EditorGroup(PARTICLES_FLOW_CAMERA,true)]
        [LoadAsset("Rain.prefab")]
        public GameObject rainVFX;

        [EditorGroup(PARTICLES_FLOW_CAMERA)]
        [LoadAsset("SnowStorm.prefab")]
         public GameObject snowVFX;

        [EditorGroup(PARTICLES_FLOW_CAMERA)] public GameObject followTarget;
        [EditorGroup(PARTICLES_FLOW_CAMERA)] public float followSpeed = 1;

        // clouds
        [EditorGroup(CLOUD_SHADOW, true)] public bool _CloudShadowOn;
        [EditorGroup(CLOUD_SHADOW)] public GameObject cloudShadowBox;
        [EditorGroup(CLOUD_SHADOW)] public Texture cloudShadowNoiseTex;

        [EditorGroup(CLOUD_SHADOW)] public Vector4 _CloudNoiseTilingOffset = new Vector4(.1f, .1f, 0, 0);
        [EditorGroup(CLOUD_SHADOW)] public bool _CloudNoiseOffsetStop;
        [EditorGroup(CLOUD_SHADOW)] [Range(0,1)] public float _CloudNoiseRangeMin = 0;
        [EditorGroup(CLOUD_SHADOW)] [Range(0,1)] public float _CloudNoiseRangeMax = 1;
        [EditorGroup(CLOUD_SHADOW)] public Color _CloudShadowColor = Color.black;
        [EditorGroup(CLOUD_SHADOW)] public float _CloudBaseShadowIntensity = 0;
        [EditorGroup(CLOUD_SHADOW)] public float _CloudShadowIntensity = 1;

        Material cloudShadowBoxMat;

        #region Shader Params
        int 
            _GlobalSkyExposure = Shader.PropertyToID(nameof(_GlobalSkyExposure)),
            _GlobalSkyOn = Shader.PropertyToID(nameof(_GlobalSkyOn)),
            _EmissionScanLineRange_Rate = Shader.PropertyToID(nameof(_EmissionScanLineRange_Rate)),
            _GlobalWindDir = Shader.PropertyToID(nameof(_GlobalWindDir))
            ;

        #endregion

        public void OnEnable()
        {
            InitWeather();
            instanceManager.Add(this);
        }

        public void OnDisable()
        {
            Shader.SetGlobalFloat(nameof(_IsGlobalFogOn), 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalRainOn), 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalSnowOn), 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalWindOn), 0);

            if (cloudShadowBox)
                cloudShadowBox.SetActive(false);

            instanceManager.Remove(this);
        }

        public void Update()
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
            Shader.SetGlobalVector(nameof(_GlobalSnowIntensity), new Vector4( Mathf.SmoothStep(0, 1, _GlobalSnowIntensity) , _GlobalSnowColor.r, _GlobalSnowColor.g, _GlobalSnowColor.b));

            var forward = transform.forward;
            Shader.SetGlobalVector(_GlobalWindDir, new Vector4(forward.x, forward.y, forward.z, _GlobalWindIntensity));

            Shader.SetGlobalFloat(nameof(_IsGlobalFogOn), _IsGlobalFogOn ? 1 : 0);

            Shader.SetGlobalTexture(nameof(_WeatherNoiseTexture), _WeatherNoiseTexture ?? Texture2D.whiteTexture);

            Shader.SetGlobalFloat(nameof(_IsGlobalRainOn), _IsGlobalRainOn ? 1 : 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalSnowOn), _IsGlobalSnowOn ? 1 : 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalWindOn), _IsGlobalWindOn ? 1 : 0);

            Shader.SetGlobalFloat(_GlobalSkyExposure, isGlobalSkyOn ? Mathf.Max(0.02f,skyExposure) : 1);

            //-------- matcap
            Shader.SetGlobalTexture(nameof(_SceneMatCap), _SceneMatCap ?? Texture2D.whiteTexture);
            Shader.SetGlobalVector(nameof(_SceneMatCap_ST), _SceneMatCap_ST);

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