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
    public class GroupVectorSliderDrawer : MaterialPropertyDrawer
    {
        const char ITEM_SPLITTER = ' ';
        const char RANGE_SPLITTER = '_';
        readonly string[] strings_XYZ = new string[] { "X","Y","Z"};

        const float LINE_HEIGHT = 18;
        string[] headers;
        Vector2[] ranges;
        string groupName;


        //public GroupVectorSliderDrawer(string headerString) : this("",headerString, "") { }
        public GroupVectorSliderDrawer(string headerString,string rangeString) : this("", headerString, rangeString) { }
        /// <summary>
        /// headerString 
        ///     4slider : a b c d, [space] is splitter
        ///     vector3 slider1 : VectorSlider(vname sname ,0_1)
        /// rangeString like 0_1 0_1 ,[space][_] is splitter
        /// 
        /// like:
        /// 
        /// [VectorSlider(branch edge globalOffset flutterOffset,0_0.4 0_0.5 0_0.6 0_0.7)]_WindAnimParam("_WindAnimParam(x:branch,edge,z : global offset,w:flutter offset)",vector) = (1,1,0.1,0.3)
        /// [VectorSlider(WindDir(xyz) intensity, 0_1)] _WindDir("_WindDir,dir:(xyz),intensity:(w)", vector) = (1,0.1,0,1)

        /// </summary>
        /// <param name="headerString"></param>
        public GroupVectorSliderDrawer(string groupName,string headerString,string rangeString)
        {
            this.groupName = groupName;
            if (!string.IsNullOrEmpty(headerString))
            {
                headers = headerString.Split(ITEM_SPLITTER);
            }
            if (!string.IsNullOrEmpty(rangeString))
            {
                var rangeItems = rangeString.Split(new[] {ITEM_SPLITTER, RANGE_SPLITTER }, StringSplitOptions.RemoveEmptyEntries);
                if (rangeItems.Length > 1)
                {
                    var halfLen = rangeItems.Length / 2;
                    ranges = new Vector2[halfLen];
                    for (int i = 0; i < halfLen; i++)
                    {
                        ranges[i] = new Vector2(Convert.ToSingle(rangeItems[i * 2]), Convert.ToSingle(rangeItems[i * 2 + 1]));
                    }
                }
                else
                    ranges[0] = new Vector2(Convert.ToSingle(rangeItems[0]),0);
            }
        }

        bool ShowUI()
        {
            var isDrawUI = string.IsNullOrEmpty(groupName);
            if (!isDrawUI)
                isDrawUI = MaterialGroupTools.IsGroupOn(groupName);
            return isDrawUI;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (ShowUI())
                return (headers.Length + 1) * LINE_HEIGHT;
            return -1;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if (prop.type != MaterialProperty.PropType.Vector || headers == null)
                editor.DrawDefaultInspector();



            if (ShowUI())
            {
                DrawUI(position, prop, label);
            }

        }

        private void DrawUI(Rect position, MaterialProperty prop, GUIContent label)
        {
            EditorGUI.BeginChangeCheck();
            var value = prop.vectorValue;

            // property label
            EditorGUI.LabelField(new Rect(position.x, position.y, position.width, LINE_HEIGHT), label);

            EditorGUI.indentLevel++;

            position.y += LINE_HEIGHT;
            position.height -= LINE_HEIGHT;

            if (headers.Length == 4)
                Draw4Sliders(position, ref value);
            else if (headers.Length == 2)
                DrawVector3Slider1(position, ref value);

            EditorGUI.indentLevel--;

            if (EditorGUI.EndChangeCheck())
            {
                prop.vectorValue = value;
            }
        }

        float DrawRemapSlider(Rect position, Vector2 range,string label, float value)
        {
            float v = EditorGUI.Slider(position,label, Mathf.InverseLerp(range.x, range.y, value), 0, 1);
            return Mathf.Lerp(range.x, range.y, v);
        }

        private void DrawVector3Slider1(Rect position, ref Vector4 value)
        {
            var vectorHeader = headers[0];
            var sliderHeader = headers[1];


            var itemWidth = position.width / 4;
            var pos = position;
            pos.height = LINE_HEIGHT;
            pos.width = itemWidth;

            EditorGUI.LabelField(pos, vectorHeader);

            EditorGUIUtility.labelWidth = 30;// EditorStyles.label.CalcSize(new GUIContent("X")).x;
            for (int i = 0; i < 3; i++)
            {
                pos.x += itemWidth;

                value[i] = EditorGUI.FloatField(pos, strings_XYZ[i], value[i]);
            }
            // slider
            pos.x = position.x ;
            pos.y += LINE_HEIGHT;
            pos.width = position.width;
            EditorGUIUtility.labelWidth = itemWidth;
            value[3] = DrawRemapSlider(pos, ranges[0],sliderHeader, value[3]);
        }

        //float Lerp(float a, float b, float t) => a + (b - a) * t;

        //public static float Remap(float min, float max, float t) => t / Mathf.Max(max - min, 0.0001f);

        private void Draw4Sliders(Rect position, ref Vector4 value)
        {
            var pos = new Rect(position.x, position.y, position.width, 18);
            for (int i = 0; i < headers.Length; i++)
            {
                value[i] = DrawRemapSlider(pos,ranges[i],headers[i], value[i]);
                pos.y += LINE_HEIGHT;

            }
        }
    }
}
#endif