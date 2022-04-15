#if UNITY_EDITOR
namespace PowerUtilities
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;
    using System.Linq;
    /// <summary>
    /// Draw Vector on Material GUI
    /// 
    /// </summary>
    public class VectorSliderDrawer : MaterialPropertyDrawer
    {
        const char ITEM_SPLITTER = ' ';
        const char RANGE_SPLITTER = '_';

        const float LINE_HEIGHT = 18;
        string[] headers;
        Vector2[] ranges;


        public VectorSliderDrawer(string headerString) : this(headerString, null) { }

        /// <summary>
        /// headerString liek : a b c d, [space] is splitter
        /// rangeString like 0_1 0_1 ,[space][_] is splitter
        /// </summary>
        /// <param name="headerString"></param>
        public VectorSliderDrawer(string headerString,string realRangeString)
        {
            if (!string.IsNullOrEmpty(headerString))
            {
                headers = headerString.Split(ITEM_SPLITTER);
            }
            if (!string.IsNullOrEmpty(realRangeString))
            {
                var rangeItems = realRangeString.Split(new[] {ITEM_SPLITTER, RANGE_SPLITTER }, StringSplitOptions.RemoveEmptyEntries);
                var halfLen = rangeItems.Length / 2;
                ranges = new Vector2 [halfLen];
                for (int i = 0; i < halfLen; i++)
                {
                    ranges[i] = new Vector2(Convert.ToSingle(rangeItems[i*2]) ,Convert.ToSingle(rangeItems[i*2+1]));
                }
            }
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return (headers.Length + 1) * LINE_HEIGHT;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if (prop.type != MaterialProperty.PropType.Vector || headers == null)
                editor.DrawDefaultInspector();

            EditorGUI.BeginChangeCheck();
            var value = prop.vectorValue;


            EditorGUI.LabelField(new Rect(position.x,position.y,position.width,LINE_HEIGHT), label);

            EditorGUI.indentLevel++;

            position.y += LINE_HEIGHT;
            position.height -= LINE_HEIGHT;

            DrawSliders(position, ref value);
            EditorGUI.indentLevel--;

            if (EditorGUI.EndChangeCheck())
            {
                prop.vectorValue = value;
            }
        }

        //float Lerp(float a, float b, float t) => a + (b - a) * t;
        /// <summary>
        /// Lerp revert
        /// </summary>
        /// <param name="min"></param>
        /// <param name="max"></param>
        /// <param name="t"></param>
        /// <returns>[0,1]</returns>
        float Remap(float min, float max, float t) => t / Mathf.Max(max - min, 0.0001f);

        private void DrawSliders(Rect position, ref Vector4 value)
        {
            var pos = new Rect(position.x, position.y, position.width, 18);
            for (int i = 0; i < headers.Length; i++)
            {
                value[i] = EditorGUI.Slider(pos, headers[i], Remap(ranges[i].x, ranges[i].y, value[i]), 0, 1);
                pos.y += LINE_HEIGHT;

                if (ranges != null && ranges.Length == headers.Length)
                    value[i] = Mathf.Lerp(ranges[i].x, ranges[i].y, value[i]);
            }
        }
    }
}
#endif