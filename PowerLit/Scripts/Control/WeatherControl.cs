namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
#if UNITY_EDITOR
    using UnityEditor;

    [CustomEditor(typeof(WeatherControl))]
    public class WeatherControlEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            WeatherControl control = (WeatherControl)target;

            EditorGUI.BeginChangeCheck();
            base.OnInspectorGUI();

            EditorGUILayout.BeginVertical("Box");
            EditorGUILayout.SelectableLabel("use transform.forward control Global Wind Dir", EditorStyles.boldLabel);
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
    public class WeatherControl : MonoBehaviour
    {
        public const string _GlobalWindDir = nameof(_GlobalWindDir);
        public const string _GlobalSnowIntensity = nameof(_GlobalSnowIntensity);

        WaitForSeconds aSecond = new WaitForSeconds(1);

        [Range(0,1)]public float globalSnowIntensity = 1;
        [Range(0, 10)] public float globalWindIntensity = 1;

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
            Shader.SetGlobalFloat(_GlobalSnowIntensity,globalSnowIntensity);

            var forward = transform.forward;
            Shader.SetGlobalVector(_GlobalWindDir, new Vector4(forward.x, forward.y, forward.z, globalWindIntensity));
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