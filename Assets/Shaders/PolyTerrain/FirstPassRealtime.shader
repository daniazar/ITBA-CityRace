Shader "PolyTerrain/Splatmap/Realtime-FirstPass" {
Properties {
	_Control ("SplatMap (RGBA)", 2D) = "red" {}
	_LightMap ("LightMap (RGB)", 2D) = "gray" {}
	_AnglePerHeight ("Angle increase per 1 m height", Float) = 0
	_Splat0 ("Layer 0 (R)", 2D) = "white" {}
	_Splat0Min ("Layer 0 Min", Float) = 0
	_Splat0Max ("Layer 0 Max", Float) = 5
	_Splat1 ("Layer 1 (G)", 2D) = "white" {}
	_Splat1Min ("Layer 1 Min", Float) = 10
	_Splat1Max ("Layer 1 Max", Float) = 12
	_Splat2 ("Layer 2 (B)", 2D) = "white" {}
	_Splat2Min ("Layer 2 Min", Float) = 20
	_Splat2Max ("Layer 2 Max", Float) = 23
	_Splat3 ("Layer 3 (A)", 2D) = "white" {}
	_Splat3Min ("Layer 3 Min", Float) = 25
	_Splat3Max ("Layer 3 Max", Float) = 90
	_BaseMap ("BaseMap (RGB)", 2D) = "white" {}
}
	
#warning Upgrade NOTE: SubShader commented out; uses Unity 2.x style fixed function per-pixel lighting. Per-pixel lighting is not supported without shaders anymore.
/*SubShader {		
	Tags {
		"SplatCount" = "4"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
	
	/* Upgrade NOTE: commented out, possibly part of old style per-pixel lighting: Blend AppSrcAdd AppDstAdd */
	Fog { Color [_AddFog] }
	
	// Ambient pass
	Pass {
		Tags { "LightMode" = "Always" /* Upgrade NOTE: changed from PixelOrNone to Always */ }
		
		CGPROGRAM
		#pragma vertex AmbientSplatVertex
		#pragma fragment AmbientSplatFragment
		#pragma fragmentoption ARB_fog_exp2
		#pragma fragmentoption ARB_precision_hint_fastest
	
		#define USE_LIGHTMAP
		#include "polysplatting.cginc"
		ENDCG
	}
	// Vertex lights
	Pass {
		Tags { "LightMode" = "Vertex" }
		
		CGPROGRAM
		#pragma vertex VertexlitSplatVertex
		#pragma fragment VertexlitSplatFragment
		#pragma fragmentoption ARB_fog_exp2
		#pragma fragmentoption ARB_precision_hint_fastest
		#define USE_LIGHTMAP
		#include "polysplatting.cginc"
		ENDCG
	}
	// Pixel lights
	Pass {
		Tags { "LightMode" = "Pixel" }
		
		CGPROGRAM
		#pragma vertex PixellitSplatVertex
		#pragma fragment PixellitSplatFragment
		#pragma fragmentoption ARB_fog_exp2
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma multi_compile_builtin
		
		#include "UnityCG.cginc"
		#include "AutoLight.cginc"
		#define INCLUDE_PIXEL
		#include "polysplatting.cginc"
		ENDCG
	}
	
	UsePass "VertexLit/SHADOWCOLLECTOR"
}*/
 	
// Fallback to Lightmap
Fallback "PolyTerrain/Splatmap/Lightmap-FirstPass"
}
