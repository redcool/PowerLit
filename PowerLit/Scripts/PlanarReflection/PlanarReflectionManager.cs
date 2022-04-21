using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanarReflectionManager : MonoBehaviour
{
    public string reflectionTexture = "_ReflectionTex";
    public float planeY;
    public LayerMask layers = -1;

    Camera reflectionCam;
    Camera mainCam;

    RenderTexture reflectionRT;

#if USE_PLANE_TRANSFORM
    public Transform reflectionPlane;
#endif
    // Start is called before the first frame update
    void Start()
    {
        reflectionCam = CreateCamera("Reflection Camera");
        mainCam = Camera.main;
        reflectionRT = new RenderTexture(Screen.width, Screen.height, 24);

#if USE_PLANE_TRANSFORM
        if (!reflectionPlane)
            enabled = false;
#endif

    }

    private void Update()
    {
        RenderReflection(planeY);
        SendToShader();
    }

    private void OnDestroy()
    {
        Destroy(reflectionRT);
    }

    private void SendToShader()
    {
        Shader.SetGlobalTexture(reflectionTexture, reflectionRT);
    }
#if USE_PLANE_TRANSFORM
    private void RenderReflection1()
    {
        reflectionCam.CopyFrom(mainCam);
        reflectionCam.targetTexture = reflectionRT;

        var camForward = mainCam.transform.forward;
        var camUp = mainCam.transform.up;
        var camPos = mainCam.transform.position;

        var camForwardPlaneSpace = reflectionPlane.InverseTransformDirection(camForward);
        var camUpPlaneSpace = reflectionPlane.InverseTransformDirection(camUp);
        var camPosPlaneSpace = reflectionPlane.InverseTransformPoint(camPos);

        camForwardPlaneSpace.y *= -1;
        camUpPlaneSpace.y *= -1;
        camPosPlaneSpace.y *= -1;

        camForward = reflectionPlane.TransformDirection(camForwardPlaneSpace);
        camUp = reflectionPlane.TransformDirection(camUpPlaneSpace);
        camPos = reflectionPlane.TransformPoint(camPosPlaneSpace);


        //reflectionCam.transform.up = camUp;
        reflectionCam.transform.position = camPos;
        //reflectionCam.transform.forward = camForward;
        reflectionCam.transform.LookAt( camForward, camUp);

        reflectionCam.Render();
    }
#endif

    
    private void RenderReflection(float planeY)
    {
        reflectionCam.CopyFrom(mainCam);
        reflectionCam.targetTexture = reflectionRT;
        reflectionCam.cullingMask = layers;

        var camForward = mainCam.transform.forward;
        var camUp = mainCam.transform.up;
        var camPos = mainCam.transform.position;

        camForward.y *= -1;
        camUp.y *= -1;
        camPos.y *= -1;

        camPos.y += planeY;

        reflectionCam.transform.position = camPos;
        reflectionCam.transform.LookAt(camPos + camForward, camUp);

        reflectionCam.Render();
    }

    Camera CreateCamera(string cameraName)
    {
        var camGo = new GameObject(cameraName);
        var cam = camGo.AddComponent<Camera>();
        cam.enabled = false;
        return cam;
    }
}
