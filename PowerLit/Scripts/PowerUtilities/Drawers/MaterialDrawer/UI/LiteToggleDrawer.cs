#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace PowerUtilities{
    /// <summary>
    /// Toggle, no Keyword
    /// </summary>
    public class LiteToggleDrawer : GroupToggleDrawer
    {
        public LiteToggleDrawer() : base() { }
        public LiteToggleDrawer(string groupName, string keyword) : base(groupName, keyword) { }
    }
}
#endif