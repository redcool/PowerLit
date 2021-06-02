using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PowerURPLitFeatures : ScriptableRendererFeature
{

    [Serializable]
    public struct Settings
    {
        public bool isActive;
        [Header("Main Light Shadow")]
        [NonSerialized] public bool _MainLightShadowOn;
        [NonSerialized] public bool _MainLightShadowCascadeOn;
        [NonSerialized] public bool _AdditionalVertexLightOn;

        [Tooltip("enabled lightmap ?")]public bool _LightmapOn;

        [Tooltip("enable shadowMask ?")]public bool _Shadows_ShadowMaskOn;
    }


    class PowerURPLitUpdateParamsPass : ScriptableRenderPass
    {
        public Settings settings;

        const string MAIN_LIGHT_MODE_ID = "_MainLightMode";
        const string ADDITIONAL_LIGHT_MODE_ID = "_AdditionalLightMode";
        public void UpdateParams(CommandBuffer cmd)
        {
            var asset = UniversalRenderPipeline.asset;

            cmd.SetGlobalInt(nameof(settings._MainLightShadowCascadeOn), asset.shadowCascadeCount>1 ? 1 : 0);
            cmd.SetGlobalInt(nameof(settings._LightmapOn),settings._LightmapOn ? 1 : 0);
            cmd.SetGlobalInt(nameof(settings._Shadows_ShadowMaskOn),settings._Shadows_ShadowMaskOn ? 1 : 0);
            cmd.SetGlobalInt(nameof(settings._MainLightShadowOn), asset.supportsMainLightShadows ? 1 : 0);
            cmd.SetGlobalInt(MAIN_LIGHT_MODE_ID, (int)asset.mainLightRenderingMode);
            cmd.SetGlobalInt(ADDITIONAL_LIGHT_MODE_ID,(int)asset.additionalLightsRenderingMode);
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            base.Configure(cmd, cameraTextureDescriptor);
            UpdateParams(cmd);
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            
        }
    }
    public Settings settings = new Settings();
    PowerURPLitUpdateParamsPass pass;


    /// <inheritdoc/>
    public override void Create()
    { 
        pass = new PowerURPLitUpdateParamsPass();
        pass.settings = settings;

    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(pass);
    }
}


