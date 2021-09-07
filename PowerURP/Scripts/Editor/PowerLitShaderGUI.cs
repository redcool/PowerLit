#if UNITY_EDITOR
namespace PowerURP
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
            AlphaTabId = 2;
        }
    }
}
#endif