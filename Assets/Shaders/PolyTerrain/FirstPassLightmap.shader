Shader "PolyTerrain/Splatmap/Lightmap-FirstPass" {
Properties {
	_Control ("SplatMap (RGBA)", 2D) = "red" {}
	_LightMap ("LightMap (RGB)", 2D) = "gray" {}
	_Splat0 ("Layer 0 (R)", 2D) = "white" {}
	_Splat1 ("Layer 1 (G)", 2D) = "white" {}
	_Splat2 ("Layer 2 (B)", 2D) = "white" {}
	_Splat3 ("Layer 3 (A)", 2D) = "white" {}
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
			#pragma vertex LightmapSplatVertex
			#pragma fragment LightmapSplatFragment
			#pragma fragmentoption ARB_fog_exp2
			#pragma fragmentoption ARB_precision_hint_fastest
			#define TEXTURECOUNT 4

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
			
			BindChannels {
				Bind "Vertex", vertex
				Bind "normal", normal
				Bind "texcoord", texcoord0 // splat 0 uses 1st uv
				Bind "texcoord", texcoord1 // splat 1 uses 1st uv
				Bind "texcoord", texcoord2 // splat 2 uses 1st uv
				Bind "texcoord", texcoord3 // splat 3 uses 1st uv
				Bind "texcoord1", texcoord4 // control uses 2nd uv
				Bind "texcoord1", texcoord5 // lightmap uses 2nd uv
			}

			Program "" {
				SubProgram {
"!!ATIfs1.0
StartConstants;
	CONSTANT c0 = {0};
EndConstants;

StartOutputPass;
	SampleMap r0, t0.str;	# splat0
	SampleMap r1, t1.str;	# splat1	
	SampleMap r2, t2.str;	# splat2	
	SampleMap r3, t3.str;	# splat3	
	SampleMap r4, t4.str;	# control
	SampleMap r5, t5.str;	# lightmap

	MUL r0.rgb, r0, r4.r;
	MAD r0.rgb, r1, r4.g, r0;
	MAD r0.rgb, r2, r4.b, r0;
	MAD r0.rgb, r3, r4.a, r0;
	MUL r0.rgb, r0.2x, r5;
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
			SetTexture [_LightMap]
		}
 	}*/
}

// Fallback to base map
Fallback "PolyTerrain/Splatmap/Lightmap-BaseMap"
}
