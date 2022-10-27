namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

#if UNITY_EDITOR
    using UnityEditor;

    [CustomEditor(typeof(PowerLitWeatherControl))]
    public class PowerLitWeatherControlEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            PowerLitWeatherControl control = (PowerLitWeatherControl)target;

            EditorGUI.BeginChangeCheck();
            base.OnInspectorGUI();

            //EditorGUILayout.BeginVertical("Box");
            //EditorGUILayout.HelpBox("Use transform.forward control Global Wind Dir",MessageType.None);
            //EditorGUILayout.EndVertical();

            if (EditorGUI.EndChangeCheck() || control.transform.hasChanged)
            {
                control.UpdateWeatherParams();
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
        WaitForSeconds aSecond = new WaitForSeconds(1);

        //[Header("Fog")]
        [EditorGroupLayout("Fog",true)]
        public bool _IsGlobalFogOn;
        [EditorGroupLayout("Fog")][Range(0,1)]public float _GlobalFogIntensity = 1;

        [EditorGroupLayout("Rain",true)]
        public bool _IsGlobalRainOn;
        [EditorGroupLayout("Rain")][Range(0, 1)] public float _GlobalRainIntensity = 1;

        [EditorGroupLayout("Snow",true)]
        public bool _IsGlobalSnowOn;
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

        #region Shader Params
        int _GlobalSkyExposure = Shader.PropertyToID(nameof(_GlobalSkyExposure));

        #endregion

        // Start is called before the first frame update
        void Start()
        {
            mainLightStartIntensity = mainLight? mainLight.intensity : 0;
            mainLightStartColor = mainLight ? mainLight.color : Color.black;

            StartCoroutine(WaitForUpdate());

            if (!followTarget)
                followTarget =Camera.main?.gameObject;

            UpdateVFX(rainVFX, _GlobalRainIntensity, _IsGlobalRainOn,true);
            UpdateVFX(snowVFX, _GlobalSnowIntensity, _IsGlobalSnowOn,true);
        }
            
        IEnumerator WaitForUpdate()
        {
            while (true)
            {
                UpdateWeatherParams();
                yield return aSecond;
            }
        }

        private void Update()
        {
            UpdateThunder();

            UpdateVFX(rainVFX,_GlobalRainIntensity,_IsGlobalRainOn);
            UpdateVFX(snowVFX, _GlobalSnowIntensity,_IsGlobalSnowOn);
        }
        public void UpdateWeatherParams()
        {
            Shader.SetGlobalFloat(nameof(_GlobalFogIntensity), _GlobalFogIntensity);
            Shader.SetGlobalFloat(nameof(_GlobalRainIntensity), _GlobalRainIntensity);
            Shader.SetGlobalFloat(nameof(_GlobalSnowIntensity), Mathf.SmoothStep(0,1,_GlobalSnowIntensity));

            var forward = transform.forward;
            Shader.SetGlobalVector("_GlobalWindDir", new Vector4(forward.x, forward.y, forward.z, _GlobalWindIntensity));

            Shader.SetGlobalFloat(nameof(_IsGlobalFogOn), _IsGlobalFogOn ? 1 : 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalRainOn), _IsGlobalRainOn ? 1 : 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalSnowOn), _IsGlobalSnowOn ? 1 : 0);
            Shader.SetGlobalFloat(nameof(_IsGlobalWindOn), _IsGlobalWindOn ? 1 : 0);
            Shader.SetGlobalFloat(_GlobalSkyExposure, isGlobalSkyOn ? skyExposure : 1);
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
        }
#endif
    }

}