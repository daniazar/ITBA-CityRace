using UnityEngine;
using System.Collections;

public class TimeCounter : MonoBehaviour {	 
	public float startTime = 60;
	 
	private float accum   = 0; // FPS accumulated over the interval
	private float timeleft; // Left time for current interval
	private int checkpointleft;
	private GameObject[] wp;
	private bool hurry = false;
	 
	void Start()
	{
	  	//Debug.Log("startTime: " + startTime);
		timeleft = startTime;
		wp = GameObject.FindGameObjectsWithTag("waypoint");		
		checkpointleft = wp.Length;
	}
	 
	void Update()
	{
		 //The time left for player to complete level
//		Debug.Log("timeleft: " + timeleft);  
		timeleft = startTime - Time.timeSinceLevelLoad;
		//Don't let the time left go below zero
		timeleft = Mathf.Max (0, timeleft);
		//Format the time nicely
		checkpointleft = getCheckpointleft();
		if (timeleft <= startTime/4)
		{
			hurry = true;
		}
		
		if(timeleft == 0)
		{
			// perdi!!! aca hay que ir al level de loose
			Application.LoadLevel("GameOver");
		}   
	}
	
	void OnGUI() 
	{
		GUI.Box(new Rect(Screen.width-160, 10, 150, 40), timeleft.ToString("f2") +"secs\nCheckpoint left: " + checkpointleft);
		
		if (hurry)
		{
			GUI.Label(new Rect(200, 150, 600, 20), "HURRY UP!!!");
		}
	}
	
	int getCheckpointleft()
	{
		int i = 0;
		foreach(GameObject g in wp) {
			CheckPoint ch = g.GetComponent<CheckPoint>();
			//Debug.Log(ch.gameObject.name);
			
			if (ch.pass == false) {
				i++;
			}
		}
		return i;
		
	}
}
