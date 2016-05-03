using UnityEngine;
using System.Collections;

public class GameSetup : MonoBehaviour {


	// Use this for initialization
	void Start () {
		SetInitialPosition();
	//StartCoroutine (SetInitialPosition());
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void  SetInitialPosition() {
		//yield return new WaitForSeconds(2f);

		GameObject[] wp = GameObject.FindGameObjectsWithTag("waypoint");
		
		
		CheckPoint ch = wp[1].GetComponent<CheckPoint>();
		ch.final = true;
		//Debug.Log("waypoint count: " + wp.Length);

		gameObject.transform.position = wp[2].transform.position;
		Vector3 pos = new Vector3(0f, 2f, 0f);
		gameObject.transform.position += pos;

		

	}
}
