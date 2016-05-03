// Converted from UnityScript to C# at http://www.M2H.nl/files/js_to_c.php - by Mike Hergaarden
// Do test the code! You usually need to change a few small bits.

using UnityEngine;
using System.Collections;

public class SoundToggler : MonoBehaviour {
public float fadeTime = 1.0f; 
private SoundController soundScript; 

void  Start (){ 
   soundScript = (SoundController) FindObjectOfType(typeof(SoundController)); 
} 

void  OnTriggerEnter (){ 
   soundScript.ControlSound(true, fadeTime); 
} 

void  OnTriggerExit (){ 
   soundScript.ControlSound(false, fadeTime); 
}
}