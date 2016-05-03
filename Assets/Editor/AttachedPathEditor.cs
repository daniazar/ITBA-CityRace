using UnityEngine;
using UnityEditor;
using System;
using System.Collections;
using System.Collections.Generic;

[CustomEditor(typeof(AttachedPathScript))]

public class AttachedPathEditor : Editor 
{
	public void OnSceneGUI()
	{
		
		AttachedPathScript pathScript = (AttachedPathScript) target as AttachedPathScript;
				
		if (pathScript.nodeObjects != null && pathScript.nodeObjects.Length != 0) 
		{
			int n = pathScript.nodeObjects.Length;
			for (int i = 0; i < n; i++) 
			{
				PathNodeObjects node = pathScript.nodeObjects[i];
				node.position = Handles.PositionHandle(node.position, Quaternion.identity);
			}
		}
		if (GUI.changed) 
		{
				pathScript.CreatePath(pathScript.pathSmooth, false);
						}
	}
	
	
	
	public override void OnInspectorGUI() 
	{
		EditorGUIUtility.LookLikeControls();
		AttachedPathScript pathScript = (AttachedPathScript) target as AttachedPathScript;
	
		EditorGUILayout.BeginHorizontal();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.PrefixLabel("Road");
			pathScript.isRoad = EditorGUILayout.Toggle(pathScript.isRoad);
			
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.BeginHorizontal();
			pathScript.waypoint = (GameObject) EditorGUILayout.ObjectField("Waypoints", pathScript.waypoint,  typeof( GameObject ));
			EditorGUILayout.EndHorizontal();
					
			EditorGUILayout.Separator();
		
	
		EditorGUILayout.EndHorizontal();
				EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.BeginHorizontal();
			pathScript.pathWidth = (int) EditorGUILayout.IntSlider("Path Width", pathScript.pathWidth, 3, 20);
			EditorGUILayout.EndHorizontal();
					
			EditorGUILayout.Separator();
			EditorGUILayout.BeginHorizontal();
			pathScript.pathSmooth = (int) EditorGUILayout.IntSlider("Mesh Smoothing", pathScript.pathSmooth, 5, 60);
			EditorGUILayout.EndHorizontal();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			
			Rect clearButton = EditorGUILayout.BeginHorizontal();
			clearButton.x = clearButton.width / 2 - 100;
			clearButton.width = 200;
			clearButton.height = 18;
			if (GUI.Button(clearButton, "Clear Mesh")) 
			{
				pathScript.ResetPath();
				GUIUtility.ExitGUI();
				
			}
			
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.EndHorizontal();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			
			Rect startButton = EditorGUILayout.BeginHorizontal();
			startButton.x = startButton.width / 2 - 100;
			startButton.width = 200;
			startButton.height = 18;
			if (GUI.Button(startButton, "Add path node")) 
			{
				// agregar un nodo al path.
				Vector3 pathNode = new Vector3(10,0,10);
							
				pathScript.AddPathNode(pathNode);
				pathNode = new Vector3(10,0,10);
				pathScript.AddPathNode(pathNode);
				pathNode = new Vector3(0,0,0);
				pathScript.AddPathNode(pathNode);
				pathNode = new Vector3(-10,0,0);
				pathScript.AddPathNode(pathNode);
				pathNode = new Vector3(-50,0,-50);
				pathScript.AddPathNode(pathNode);
				GUIUtility.ExitGUI();
			}
			
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.EndHorizontal();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();

			AttachedPathScript.randomSeed = EditorGUILayout.IntField("Random seed", AttachedPathScript.randomSeed);
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.BeginHorizontal();
			pathScript.elipticNodes = EditorGUILayout.IntSlider("Number of nodes", pathScript.elipticNodes, 5, 150);
			EditorGUILayout.EndHorizontal();

			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.BeginHorizontal();
			pathScript.elipticRadiusA =  EditorGUILayout.Slider("Radius A", pathScript.elipticRadiusA, 10, 2000);
			EditorGUILayout.EndHorizontal();

			
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.BeginHorizontal();
			pathScript.elipticRadiusB =  EditorGUILayout.Slider("Radius B", pathScript.elipticRadiusB, 10, 2000);
			EditorGUILayout.EndHorizontal();
			
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.BeginHorizontal();
			pathScript.MaxRandomA =  EditorGUILayout.IntSlider("Max Random A", pathScript.MaxRandomA, 10, 2000);
			EditorGUILayout.EndHorizontal();
			
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.BeginHorizontal();
			pathScript.MaxRandomB =  EditorGUILayout.IntSlider("Max Random B", pathScript.MaxRandomB, 10, 2000);
			EditorGUILayout.EndHorizontal();

			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			startButton = EditorGUILayout.BeginHorizontal();
			startButton.x = startButton.width / 2 - 100;
			startButton.width = 200;
			startButton.height = 18;
			if (GUI.Button(startButton, "Add Complex Eliptic path")) 
			{
				// agregar un nodo al path.
//http://stackoverflow.com/questions/2280142/calculate-points-to-create-a-curve-or-spline-to-draw-an-elipse
				//x = a cos theta
				//y = b sin theta			
				AttachedPathScript.randomSeed = new System.Random().Next();
				pathScript.GenerateElipicPath();
				
					GUIUtility.ExitGUI();
			}
		
		
			EditorGUILayout.EndHorizontal();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			startButton = EditorGUILayout.BeginHorizontal();
			startButton.x = startButton.width / 2 - 100;
			startButton.width = 200;
			startButton.height = 18;
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
		
			if (GUI.Button(startButton, "Add Easy Eliptic path")) 
			{

				AttachedPathScript.randomSeed = new System.Random().Next();
				pathScript.GenerateEasyElipicPath();
				
					GUIUtility.ExitGUI();
			}
			
			
			
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.EndHorizontal();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();

			Rect endButton = EditorGUILayout.BeginHorizontal();
			endButton.x = endButton.width / 2 - 100;
			endButton.width = 200;
			endButton.height = 18;
			
			if (GUI.Button(endButton, "Finalize Path")) 
			{
								// finalize path
					pathScript.FinalizePath();
					pathScript.pathMesh.renderer.enabled = true;
				GUIUtility.ExitGUI();
			}
			EditorGUILayout.Separator();
			EditorGUILayout.Separator();
			EditorGUILayout.EndHorizontal();
		
		
		EditorGUILayout.Separator();
		EditorGUILayout.Separator();
		EditorGUILayout.Separator();
		
	}
	
}
