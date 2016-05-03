using UnityEngine;
using System;
using System.Collections;

public class AICarOut : MonoBehaviour {

	public int ReturnTimer =  10;
	private bool outOfRoad = false;

	private float timer;
	public float delay = 2;
	public AttachedPathScript path;
	public GameObject car;
	public GameObject carPos;
	private float tim;
	public Vector3 offset;
	public AICar aicar;
/*	// Update is called once per frame
	void Update () {
	if (Input.GetButtonDown("pause")) {
		transform.position = new Vector3(transform.position.x, transform.position.y - 5  , transform.position.z); 	
				
	    }	
	}
	*/
	
	void Start(){
		returnCar();
	}
	
	void Update(){
		tim +=  Time.deltaTime; 
		if( tim >= delay)
			fireRay();
		if(	outOfRoad){
			timer +=  Time.deltaTime;
		if(timer >= ReturnTimer)
			returnCar();
		}
//		Debug.Log("timer: " + timer);  
		
	}	
	void returnCar(){

		car.transform.position = AttachedPathScript.actualWaypoint.transform.position;
		
		car.transform.position += offset;

		outOfRoad = false;
		timer = 0;
					string name = AttachedPathScript.actualWaypoint.name;
			string[] aux = name.Split('_');
			
			int presentCheckpointNumber = Convert.ToInt32(aux[1]);
		Debug.Log(presentCheckpointNumber * 2);
		aicar.currentWaypoint = presentCheckpointNumber * 2 ;
		
	}

	void fireRay () {
		Vector3 direction = Camera.main.transform.up;
		direction = direction * -1f;
		RaycastHit hit;
		Vector3 pos = carPos.transform.position;
				pos += new Vector3(0f, 5f, 0f);
		

		// Did we hit anything?
		if (Physics.Raycast (pos, direction, out hit, 40)) {
			//Debug.Log(hit.collider.gameObject.tag );
			//Debug.Log(hit.collider.gameObject.name );
			if(hit.collider.gameObject.tag  == "path" || hit.collider.gameObject.tag  == "waypoint" )
			{	
				outOfRoad = false;
				timer = 0;
			}else{
				outOfRoad = true;			
			}				
		}			
	tim = 0;
	}
	

}
