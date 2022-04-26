using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class SSAO : ScriptableRendererFeature
{
    [Serializable]
    public class Settings
    {
        [Range(1,100)]public int samples = 7;
        public bool downSample;
        public float radius=0.07f;
        public float intensity = 1;
    }

    class SSAOPass : ScriptableRenderPass
    {
        Settings settings;

        int _SSAOTexture = Shader.PropertyToID("_SSAOTexture");
        int _BlurTexture = Shader.PropertyToID("_BlurTexture");
        int _ResultTex = Shader.PropertyToID("_ResultTex");

        int _SampleCount = Shader.PropertyToID("_SampleCount");
        int _Intensity = Shader.PropertyToID("_Intensity");
        int _Radius = Shader.PropertyToID("_Radius");
        int _DownSample = Shader.PropertyToID("_Downsample");

        Material mat;

        public SSAOPass(Settings settings)
        {
            this.settings = settings;
        }
        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            ref var cameraData = ref renderingData.cameraData;

            var desc = cameraData.cameraTargetDescriptor;
            var downSample = settings.downSample ? 1 : 0;
            var w = desc.width >> downSample;
            var h = desc.height >> downSample;
            desc.width = w;
            desc.height = h;

            cmd.GetTemporaryRT(_SSAOTexture, desc);
            cmd.GetTemporaryRT(_BlurTexture,desc.width>>1,desc.height>>1);
            cmd.GetTemporaryRT(_ResultTex, cameraData.cameraTargetDescriptor);

            if (!mat)
            {
                //mat = new Material(Shader.Find("Hidden/PowerFeature/SSAO"));
                mat = new Material(Shader.Find("Hidden/Kino/Obscurance"));
            }

            mat.SetFloat(_SampleCount,settings.samples);
            mat.SetFloat(_Intensity,settings.intensity);    
            mat.SetFloat(_Radius,settings.radius);
            mat.SetFloat(_DownSample, settings.downSample ? 0.5f : 1);
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get(nameof(SSAOPass));
            cmd.BeginSample(nameof(SSAOPass));
            var renderer = renderingData.cameraData.renderer;

            cmd.Blit( renderer.cameraColorTarget, _SSAOTexture, mat, 0);

            cmd.Blit(_SSAOTexture, _BlurTexture, mat, 1);
            cmd.Blit(_BlurTexture, _SSAOTexture, mat, 2);

            cmd.SetGlobalTexture("_OcclusionTexture", _SSAOTexture);
            cmd.Blit(renderer.cameraColorTarget, _ResultTex, mat, 3);

            cmd.Blit(_ResultTex, renderer.cameraColorTarget);

            cmd.EndSample(nameof(SSAOPass));
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(_SSAOTexture);
        }
    }

    SSAOPass ssaoPass;

    public Settings m_Settings = new Settings();

    /// <inheritdoc/>
    public override void Create()
    {
        ssaoPass = new SSAOPass(m_Settings);

        // Configures where the render pass should be injected.
        ssaoPass.renderPassEvent = RenderPassEvent.AfterRenderingSkybox;
         
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(ssaoPass);
    }
}


