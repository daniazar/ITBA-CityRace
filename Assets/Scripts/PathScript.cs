using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode()]

public class PathScript : MonoBehaviour 
{
	
	public Material PathMaterial;
	
	public void Start()
	{
		
	}
	
	public void NewPath()
	{
		GameObject pathMesh = new GameObject();
		pathMesh.name = "Path";
		pathMesh.AddComponent(typeof(MeshFilter));
		pathMesh.AddComponent(typeof(MeshRenderer));
		pathMesh.AddComponent<AttachedPathScript>();
		pathMesh.GetComponent<Renderer>().material = PathMaterial;
		AttachedPathScript APS = (AttachedPathScript)pathMesh.GetComponent("AttachedPathScript");
		APS.pathMesh = pathMesh;
		
		/*GameObject bordr = new GameObject();
		APS.bordr = bordr;
		bordr.name = "Border";
		bordr.AddComponent(typeof(MeshFilter));
		bordr.AddComponent(typeof(MeshRenderer));
		bordr.AddComponent(typeof(MeshCollider));
		bordr.renderer.material = PathMaterial;*/
		
	
		APS.NewPath();

	}
}

	
