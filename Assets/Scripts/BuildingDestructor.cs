using UnityEngine;
using System.Collections;

public class BuildingDestructor : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
/*	// Update is called once per frame
	void Update () {
	if (Input.GetButtonDown("pause")) {
		transform.position = new Vector3(transform.position.x, transform.position.y - 5  , transform.position.z); 	
				
	    }	
	}
	*/
	//Destruye los edificios que pisan a la pista
	void OnTriggerEnter (Collider otherObject)
	{
		if(otherObject.tag == "city")
		Destroy(otherObject.gameObject);
	}
	
	void OnTriggerStay(Collider otherObject)
	{
	//Aca deberia chequearse si el player estar si esta afuera de la pista que muestre un mensaje. o en un OnTriggerExit
		
	}
}
