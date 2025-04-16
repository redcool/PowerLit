namespace PowerUtilities
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading.Tasks;
    using UnityEngine;
    using static PowerUtilities.PowerLitWeatherControl;

    /// <summary>
    /// Override PowerLitWeatherControl's settings
    /// 
    /// </summary>
    [Serializable]
    public class PowerLitWeatherSettings : ScriptableObject
    {
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
        [EditorGroup(FOG, true)]
        public bool _IsGlobalFogOn;
        [EditorGroup(FOG)][Range(0, 1)] public float _GlobalFogIntensity = 1;

        [EditorGroup(RAIN, true)]
        public bool _IsGlobalRainOn;
        [EditorGroup(RAIN)][Range(0, 1)] public float _GlobalRainIntensity = 1;

        [EditorGroup(SNOW, true)]
        public bool _IsGlobalSnowOn;
        [EditorGroup(SNOW)][ColorUsage(true, true)] public Color _GlobalSnowColor = Color.white;
        [EditorGroup(SNOW)][Range(0, 1)] public float _GlobalSnowIntensity = 1;

        [EditorGroup(WIND, true)]
        public bool _IsGlobalWindOn;
        [EditorGroup(WIND)][Range(0, 15)] public float _GlobalWindIntensity = 1;

        [EditorGroup(THUNDER, true)]
        public bool thunderOn;
        [EditorGroup(THUNDER)] public Light mainLight;
        [EditorGroup(THUNDER)] public ThunderMode thunderMode;
        [EditorGroup(THUNDER)] public AnimationCurve thunderCurve;
        [EditorGroup(THUNDER)] public Gradient thunderColor;
        [EditorGroup(THUNDER)][Min(0.1f)] public float thunderTime = 3;
        [EditorGroup(THUNDER)] public Vector2 thunderInvervalTime = new Vector2(1, 10);

        [EditorGroup(SKY, true)] public bool isGlobalSkyOn;
        [EditorGroup(SKY)][Range(0, 1)] public float skyExposure;


        [EditorGroup(PARTICLES_FLOW_CAMERA, true)]
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
        [EditorGroup(CLOUD_SHADOW)][Range(0, 1)] public float _CloudNoiseRangeMin = 0;
        [EditorGroup(CLOUD_SHADOW)][Range(0, 1)] public float _CloudNoiseRangeMax = 1;
        [EditorGroup(CLOUD_SHADOW)] public Color _CloudShadowColor = Color.black;
        [EditorGroup(CLOUD_SHADOW)] public float _CloudBaseShadowIntensity = 0;
        [EditorGroup(CLOUD_SHADOW)] public float _CloudShadowIntensity = 1;


        /// <summary>
        /// Others 
        /// </summary>
        [EditorGroup("Others",true)]
        [Tooltip("use this setting in fadingTime")]
        [Min(0)]
        public float fadingTime = 2;

        [EditorGroup("Others")]
        [Tooltip("probability when select weather")]
        public float probability = 0.5f;

        [EditorGroup("Others")]
        [EditorDisableGroup]
        public Vector2 probabilityRange = new Vector2(0, 1);
    }
}
