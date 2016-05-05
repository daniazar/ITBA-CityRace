Shader "PolyTerrain/Splatmap/Vertexlit-FirstPass" {
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
	
Category {
	// Fragment program, 4 splats per pass
	SubShader {		
		Tags {
			"SplatCount" = "4"
			"Queue" = "Geometry-100"
			"RenderType" = "Opaque"
		}
		Pass {
			Tags { "LightMode" = "Always" }
			
			CGPROGRAM
			#pragma vertex VertexlitSplatVertex
			#pragma fragment VertexlitSplatFragment
			#pragma fragmentoption ARB_fog_exp2
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "polysplatting.cginc"
			ENDCG
		}
 	}
 	
 	// ATI texture shader, 4 splats per pass
	#warning Upgrade NOTE: SubShader commented out because of manual shader assembly
/*SubShader {		
		Tags {
			"SplatCount" = "4"
			"Queue" = "Geometry-100"
			"RenderType" = "Opaque"
		}
		Pass {
			Tags { "LightMode" = "Always" }
			Material {
				Diffuse (1, 1, 1, 1)
				Ambient (1, 1, 1, 1)
			}
			Lighting On
			
			Program "" {
				SubProgram {
"!!ATIfs1.0
StartConstants;
	CONSTANT c0 = {0};
EndConstants;

StartOutputPass;
	SampleMap r0, t0.str;	# splat0
	SampleMap r1, t1.str;	# splat0	
	SampleMap r2, t2.str;	# splat0	
	SampleMap r3, t3.str;	# splat0	
	SampleMap r4, t4.str;	# control

	MUL r0.rgb, r0, r4.r;
	MAD r0.rgb, r1, r4.g, r0;
	MAD r0.rgb, r2, r4.b, r0;
	MAD r0.rgb, r3, r4.a, r0;
	MUL r0.rgb, r0.2x, color0;
	MOV r0.a, c0;
EndPass; 
"
				}
			}
			SetTexture [_Splat0] 
			SetTexture [_Splat1] 
			SetTexture [_Splat2] 
			SetTexture [_Splat3] 
			SetTexture [_Control]
		}
 	}*/
}

// Fallback to base map	
Fallback "PolyTerrain/Splatmap/VertexLit-BaseMap"
}
