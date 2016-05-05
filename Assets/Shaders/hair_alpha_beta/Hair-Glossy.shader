Shader "Hair/Specular" {
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
		// Ambient pass (cutoff)
		Pass {
			Name "BASE"
			Tags {"LightMode" = "Always" /* Upgrade NOTE: changed from PixelOrNone to Always */}
			Blend Off
			Cull Off
			AlphaTest GEqual [_Cutoff]
			ZWrite On
			ColorMask RGB
			Color [_PPLAmbient]
			SetTexture [_MainTex] {constantColor [_Color] Combine texture * primary DOUBLE, texture}
		}
		// Ambient pass (blend)
		Pass {
			Name "BASEBLEND"
			Cull Off
			Tags {"LightMode" = "Always" /* Upgrade NOTE: changed from PixelOrNone to Always */}
			Blend SrcAlpha OneMinusSrcAlpha
			AlphaTest Off
			ZTest Less
			ZWrite Off
			ColorMask RGB
			Color [_PPLAmbient]
			SetTexture [_MainTex] {constantColor [_Color] Combine texture * primary DOUBLE, texture}
		}
		// Vertex lights - cutoff
		Pass {
			Name "BASE"
			Tags {"LightMode" = "Vertex"}
			Lighting On
			Cull Off
			AlphaTest GEqual [_Cutoff]
			ColorMask RGB
			Blend Off
			ZWrite On
			Material {
				Diffuse [_Color]
				Emission [_PPLAmbient]
				Specular [_SpecColor]
				Shininess [_Shininess]
			}
			SeparateSpecular On

CGPROGRAM
#pragma fragment vertex_frag
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest

#include "Hair_Helper.cginc"
ENDCG
		}

		// Vertex lights - blend
		Pass {
			Name "BASEBLEND"
			Tags {"LightMode" = "Vertex"}
			Lighting On
			Cull Off
			AlphaTest Off
			ZTest Less
			ZWrite Off
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			Material {
				Diffuse [_Color]
				Emission [_PPLAmbient]
				Specular [_SpecColor]
				Shininess [_Shininess]
			}
			SeparateSpecular On

CGPROGRAM
#pragma fragment vertex_frag
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest

#include "Hair_Helper.cginc"

ENDCG
		}
		
		// Pixel passes
		Pass {
			Name "PPL"
			Tags {"LightMode" = "Pixel"}
			Blend SrcAlpha One
			ColorMask RGB

CGPROGRAM
#pragma vertex vert_pixel_specular
#pragma fragment frag_pixel_specular
#pragma multi_compile_builtin			
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest

#define PIXEL_PASS_SPECULAR
#include "Hair_Helper.cginc"

ENDCG
		}
		
	}*/
}

Fallback "Transparent/Cutout/Specular", 0

}
