using UnityEngine;
using System;
using System.Collections;

public class CheckPoint : MonoBehaviour {

	public bool pass = false;
	public bool final = false;
	public Light visible;
	private bool missed = false;
	
	// Use this for initialization
	void Start () {
		
	
	}
	
	// Update is called once per frame
	void Update () {
	}
	
	void OnTriggerEnter (Collider otherObject)
	{
		if(otherObject.gameObject.tag.ToString() == "player"){
			AttachedPathScript.VerifyLocation(gameObject);
			visible.color = Color.Lerp(Color.green , Color.red, 1f);
			pass = true;
			AttachedPathScript.actualWaypoint = gameObject;
			
			string name = gameObject.name;
			string[] aux = name.Split('_');
			
			int presentCheckpointNumber = Convert.ToInt32(aux[1]);
			int lastCheckpointNumber = /*  presentCheckpointNumber == 0 ? GameObject.FindGameObjectsWithTag("waypoint").Length -1 :*/  presentCheckpointNumber - 1;
			if(lastCheckpointNumber < 0)
				lastCheckpointNumber = 0;
			
			string lastCheckpointName = "WayPoint_" + lastCheckpointNumber ;
			//Debug.Log(lastCheckpointName);
			//Debug.Log(gameObject.name);
			GameObject lastCheckpointGo = GameObject.Find(lastCheckpointName);
			CheckPoint lastCheckpoint = lastCheckpointGo.GetComponent<CheckPoint>();
			//chequeo que no sea el checkponit numero 1 porq es cuando comienza el juego
			if (GameObject.FindGameObjectsWithTag("waypoint").Length -1 != presentCheckpointNumber &&  lastCheckpoint.pass == false)
			{
//					Debug.Log("me pase un checkpoint");
				missed = true;
			}	
			else
			{
				missed = false;
			}
			
//			Debug.Log("paso por " + gameObject.name);
			
			if (isAllCheckPointsPassed()) {
				Application.LoadLevel("Win");
			}
		}
	}
	
	private bool isAllCheckPointsPassed() {
		GameObject[] checkPoints = GameObject.FindGameObjectsWithTag("waypoint");
		int i = 0;
		foreach(GameObject g in checkPoints) {
			CheckPoint ch = g.GetComponent<CheckPoint>();
			//Debug.Log(ch.gameObject.name);
			
			if (ch.pass == false) {
//				Debug.Log("cantidad de chk que pase: " + i);
				return false;
			}
			i++;
		}
		
		return true;
	}
	
	void OnGUI() 
	{
		
		if (missed)
		{
			GUI.Label(new Rect(200, 300, 600, 20), "you missed a checkpoint!!!");
		}
		
	}
	
	
}
