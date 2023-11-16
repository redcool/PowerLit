#if UNITY_EDITOR
namespace PowerUtilities
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;
    using System.Linq;

    public class FastLitShaderGUI : PowerShaderInspector
    {
        public FastLitShaderGUI()
        {
            shaderName = "FastLit";
            //isLayoutUseJson = true;
        }
    }
}
#endif