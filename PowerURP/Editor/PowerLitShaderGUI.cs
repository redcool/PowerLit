#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Linq;

public class PowerLitShaderGUI : ShaderGUI
{
    MaterialProperty[] properties;
    MaterialEditor materialEditor;
    Material material;

    MaterialGlobalIlluminationFlags[] lastFlags;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        this.properties = properties;
        this.material = materialEditor.target as Material;
        this.materialEditor = materialEditor;

        lastFlags = SaveLastFlags(materialEditor.targets);

        DrawMainUI();
    }

    MaterialGlobalIlluminationFlags[] SaveLastFlags(UnityEngine.Object[] targets)
    {
        return targets.Select(item => (Material)item)
            .Select(item => item.globalIlluminationFlags)
            .ToArray();
    }

    void DrawMainUI()
    {
        DrawEmission();
    }

    void DrawEmission()
    {
        var map = FindProperty("_EmissionMap",properties);
        var isOn = FindProperty("_EmissionOn",properties);
        var color = FindProperty("_EmissionColor",properties);
        var isBakedEmissionOn = FindProperty("_BakeEmissionOn", properties);
        
        if (isBakedEmissionOn.floatValue > 0)
        {
            foreach (Material m in materialEditor.targets)
            {
                m.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
            }
        }else
        {
            //for (int i = 0; i < materialEditor.targets.Length; i++)
            //{
            //    var m = materialEditor.targets[i] as Material;
            //    m.globalIlluminationFlags = lastFlags[i];
            //}
            foreach (Material m in materialEditor.targets)
            {
                m.globalIlluminationFlags = MaterialGlobalIlluminationFlags.None;
            }
        }
    }
}
#endif