// Converted from UnityScript to C# at http://www.M2H.nl/files/js_to_c.php - by Mike Hergaarden
// Do test the code! You usually need to change a few small bits.

using UnityEngine;
using System.Collections;

public class CrashController : MonoBehaviour {
public SoundController sound;


private MyCar car;


void Start() {
	sound = transform.root.GetComponent<SoundController>();
	car = transform.GetComponent<MyCar>();
}

void  OnCollisionEnter ( Collision collInfo  ){
	if(enabled)
	{
		float volumeFactor = Mathf.Clamp01(collInfo.relativeVelocity.magnitude * 0.08f);
		volumeFactor *= Mathf.Clamp01(0.3f + Mathf.Abs(Vector3.Dot(collInfo.relativeVelocity.normalized, collInfo.contacts[0].normal)));
		volumeFactor = volumeFactor * 0.5f + 0.5f;
		sound.Crash(volumeFactor);
	}
}
}