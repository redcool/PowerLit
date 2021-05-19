#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PowerLitShaderGUI : ShaderGUI
{
    MaterialProperty[] properties;
    MaterialEditor materialEditor;
    Material material;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        this.properties = properties;
        this.material = materialEditor.target as Material;
        this.materialEditor = materialEditor;


        DrawMainUI();
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
        if (isOn.floatValue > 0)
        {
            foreach (Material m in materialEditor.targets)
            {
                m.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
            }
        }else
        {
            foreach (Material m in materialEditor.targets)
            {
                m.globalIlluminationFlags = MaterialGlobalIlluminationFlags.None;
            }
        }
    }
}
#endif