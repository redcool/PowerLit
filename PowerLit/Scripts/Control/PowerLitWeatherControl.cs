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

            EditorGUILayout.BeginVertical("Box");
            EditorGUILayout.HelpBox("Use transform.forward control Global Wind Dir",MessageType.None);
            EditorGUILayout.EndVertical();

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

        [Header("Fog")]
        public bool _IsGlobalFogOn;
        [Range(0,1)]public float _GlobalFogIntensity = 1;

        [Header("Rain")]
        public bool _IsGlobalRainOn;
        [Range(0, 1)] public float _GlobalRainIntensity = 1;

        [Header("Snow")]
        public bool _IsGlobalSnowOn;
        [Range(0,1)]public float _GlobalSnowIntensity = 1;

        [Header("Wind")]
        public bool _IsGlobalWindOn;
        [Range(0, 15)] public float _GlobalWindIntensity = 1;

        [Header("Thunder")]
        public bool thunderOn;
        public Light mainLight;
        public ThunderMode thunderMode;
        public AnimationCurve thunderCurve;
        public PowerGradient thunderColor;
        [Min(0.1f)]public float thunderTime = 3;
        public Vector2 thunderInvervalTime = new Vector2(1, 10);

        float thunderStartTime;
        float mainLightStartIntensity;
        Color mainLightStartColor;

        // Start is called before the first frame update
        void Start()
        {
            mainLightStartIntensity = mainLight? mainLight.intensity : 0;
            mainLightStartColor = mainLight ? mainLight.color : Color.black;

            StartCoroutine(WaitForUpdate());
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