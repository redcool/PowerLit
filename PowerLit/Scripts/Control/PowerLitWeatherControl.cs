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

        // Start is called before the first frame update
        void Start()
        {
            StartCoroutine(WaitForUpdate());
        }
            
        IEnumerator WaitForUpdate()
        {
            while (true)
            {
                yield return aSecond;
                UpdateWeatherParams();
            }
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