#if !define(DEPTH_ONLY_PASS_HLSL)
#define DEPTH_ONLY_PASS_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

struct appdata{
    half4 pos:POSITION;
    half2 uv:TEXCOORD;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct v2f{
    half4 pos:SV_POSITION;
    half2 uv:TEXCOORD;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

v2f vert(appdata input){
    v2f output = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    output.pos = TransformObjectToHClip(input.pos);
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    return output;
}
half4 frag(v2f input):SV_Target{
    half4 col = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv) * _Color;
    if(_ClipOn){
        clip(col - _Cutoff);
    }
    return 0;
}
#endif //DEPTH_ONLY_PASS_HLSL