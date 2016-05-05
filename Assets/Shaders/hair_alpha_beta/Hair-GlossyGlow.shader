Shader "Hair/Specular Glow" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
	_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
	_Cutoff ("Alpha Cutoff", Range (0, 1)) = 0.5
	_MainTex ("Base (RGB) Opacity (A)", 2D) = "white" {}
	_SpecMap ("Gloss (A)", 2D) = "white" {}
}

Category { 
	/* Upgrade NOTE: commented out, possibly part of old style per-pixel lighting: Blend AppSrcAdd AppDstAdd */

	Fog { Color [_AddFog] }
	
	// ------------------------------------------------------------------
	// ARB fragment program
	
	#warning Upgrade NOTE: SubShader commented out; uses Unity 2.x style fixed function per-pixel lighting. Per-pixel lighting is not supported without shaders anymore.
/*SubShader {

		UsePass "Hair/Specular/BASE"
		UsePass "Hair/Specular/BASEBLEND"
		UsePass "Hair/Specular/PPL"


		// Vertex lights - blend
		Pass {
			Name "GLOW"
			Tags {"LightMode" = "Vertex"}
			Lighting On
			Cull Off
			AlphaTest Off
			ZTest LEqual
			ZWrite Off
			ColorMask RGBA
			Blend One One
			Material {
				Diffuse [_Color]
				Emission [_PPLAmbient]
				Specular [_SpecColor]
				Shininess [_Shininess]
			}
			SeparateSpecular On

CGPROGRAM
#pragma fragment vertex_frag_glow
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest

#include "Hair_Helper.cginc"

ENDCG
		}


		// Pixel passes
		Pass {
			Name "GLOW"
			Tags {"LightMode" = "Pixel"}
			Cull Off
			AlphaTest Off
			ZTest LEqual
			ZWrite Off
			ColorMask RGBA
			Blend One One

CGPROGRAM
#pragma vertex vert_pixel_specular_glow
#pragma fragment frag_pixel_specular_glow
#pragma multi_compile_builtin			
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest

#define PIXEL_PASS_SPECULAR_GLOW
#include "Hair_Helper.cginc"

ENDCG
		}
	}*/

}

Fallback "Hair/Specular", 0

}
