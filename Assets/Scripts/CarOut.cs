using UnityEngine;
using System.Collections;

public class CarOut : MonoBehaviour {

	public int ReturnTimer =  10;
	public int StartCount = 2;
	private bool outOfRoad = false;
	private bool 	showMes = false;
	private float timer;
	public float delay = 2;
	public AttachedPathScript path;
	public GameObject car;
	public GameObject carPos;
	private float tim;
	
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
		if(timer >= StartCount)
				showMes = true;
		if(timer >= ReturnTimer)
			returnCar();
		}
//		Debug.Log("timer: " + timer);  
		
	}	
	void returnCar(){

		car.transform.position = AttachedPathScript.actualWaypoint.transform.position;
		Vector3 pos = new Vector3(0f, 5f, 0f);
		car.transform.position += pos;

		outOfRoad = false;
		showMes = false;
		timer = 0;
		
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
				showMes = false;
				timer = 0;
			}else{
				outOfRoad = true;			
			}				
		}			
	tim = 0;
	}
	
		void OnGUI() 
	{
		if(showMes)
			GUI.Box(new Rect(10, 10, 200, 48), "Out of Road\n you will be ported in: " + (ReturnTimer - timer).ToString("f2") +"secs");
	}

}
