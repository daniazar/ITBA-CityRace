using UnityEngine;
using System.Collections;

[ExecuteInEditMode()] 
public class MainMenu : MonoBehaviour {
	public GUISkin skin;
	private string instructionText = "Press Left, Right to steer.\nPress up to accelerate.\nTo win you need to do a complete lap.";
	public int buttonWidth = 200;
	public int buttonHeight = 50;
	public int groupWidth = 300;
	public int groupHeight = 450;
	public int separator = 10;
	public int titlepos = 100;
	public int titleHeight = 30;
	
	private Rect windowRect;
	private bool showMapInfo = false;
	private bool showInstructions = false;
	public AttachedPathScript path;
	private int seed = 0;
      
	void OnGUI()
	{
			GUI.Box (new Rect (Screen.width / 2 - groupWidth / 2, Screen.height / 2 - groupHeight / 2 , groupWidth, groupHeight), "", GUI.skin.GetStyle("box"));
	        GUI.Label (new Rect (groupWidth/2 + 60, titlepos, groupWidth, groupHeight), "City Racing", skin.GetStyle("LoseSkin"));
          
		
			if(GUI.Button(new Rect(Screen.width / 2 - buttonWidth / 2, titlepos + titleHeight , buttonWidth, buttonHeight), "Start Normal Game "))
			{
				Application.LoadLevel("City");
			}
			if(GUI.Button(new Rect(Screen.width / 2 - buttonWidth / 2,titlepos + titleHeight + buttonHeight + separator, buttonWidth, buttonHeight), "Change Map"))
			{
			showMapInfo = !showMapInfo;
			}
			if(GUI.Button(new Rect(Screen.width / 2 - buttonWidth / 2, titlepos + titleHeight + 2*buttonHeight + 2*separator, buttonWidth, buttonHeight), "Instructions"))
			{
			showInstructions = !showInstructions;
			}
		
   		if (showInstructions){
        	GUI.color = Color.red;  
    		windowRect = GUI.Window(0, new Rect (10 ,  10 , 200, 300), DoInstructionsWindow, "Instructions");
		}

   		if (showMapInfo){
        	GUI.color = Color.green;  
    		windowRect = GUILayout.Window(1, new Rect (Screen.width / 2 ,  10 , 120, 50), DoMapInfoWindow, "Map info");
		}
		//http://docs.unity3d.ru/ScriptReference/GUI.Window.html
	}	
	

	
	void DoMapInfoWindow (int windowID) {
	    if (GUILayout.Button ("Random EasyMap")){
			AttachedPathScript.randomSeed = new System.Random().Next();
			seed = AttachedPathScript.randomSeed;
			path.GenerateEasyElipicPath();
			
		}
		GUILayout.Label( "Random seed:");
		try{
		seed =int.Parse(GUILayout.TextField( "" +seed, 25));
		}catch{
			
		}
		if (GUILayout.Button ("EasyMap")){
			AttachedPathScript.randomSeed = seed;
			path.GenerateEasyElipicPath();
			
		}
	    if (GUILayout.Button ("Close")){
			showMapInfo = false;
		}

	}
	
	void DoInstructionsWindow (int windowID) {
		GUILayout.Label( instructionText);
	    if (GUILayout.Button ("Close")){
			showInstructions = false;
		}
	
	}
	
}
