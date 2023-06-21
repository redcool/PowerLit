#if UNITY_EDITOR
namespace PowerUtilities
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;
    using System.Linq;

    public class PowerLitShaderGUI : PowerShaderInspector
    {
        public PowerLitShaderGUI()
        {
            shaderName = "PowerLit";
            //isLayoutUseJson = true;
        }
    }
}
#endif