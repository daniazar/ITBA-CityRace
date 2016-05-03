using UnityEngine;
using UnityEditor;
using System;
using System.Collections;
using System.Collections.Generic;

[CustomEditor(typeof(PathScript))]

public class PathEditor : Editor 
{
	public override void OnInspectorGUI() 
	{
		
		DrawDefaultInspector();
		EditorGUIUtility.LookLikeControls();
		
		PathScript pathScript = (PathScript) target as PathScript;
		
	
		EditorGUILayout.Separator();
		EditorGUILayout.Separator();
		Rect startButton = EditorGUILayout.BeginHorizontal();
		startButton.x = startButton.width / 2 - 100;
		startButton.width = 200;
		startButton.height = 18;
		
		if (GUI.Button(startButton, "New Path")) 
		{
			pathScript.NewPath();
			
			GUIUtility.ExitGUI();
		}
		
		EditorGUILayout.Separator();
		EditorGUILayout.Separator();
		EditorGUILayout.Separator();
		EditorGUILayout.EndHorizontal();
		EditorGUILayout.Separator();
		EditorGUILayout.Separator();
		EditorGUILayout.Separator();
		
		if (GUI.changed) 
		{
			EditorUtility.SetDirty(pathScript);
		}
	}
}