Shader "PolyTerrain/Splatmap/GenerateBaseMap" {
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
	SubShader {
		Tags {
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
		}

		Pass {
			Tags { "LightMode" = "Always" }
			Cull Off
			Blend Off
			ZTest Always
			ColorMask RGBA
			CGPROGRAM
			#pragma vertex vert
	//		#pragma fragment LightmapSplatFragment
			#pragma fragment frag
			#pragma fragmentoption ARB_fog_exp2
			#pragma fragmentoption ARB_precision_hint_fastest
	
			#define USE_LIGHTMAP
			#include "polysplatting.cginc"
	
		struct appdata_basemap {
		    float4 vertex : POSITION;
		    float2 texcoord : TEXCOORD0;
		    float2 texcoord1 : TEXCOORD1;
		};

			struct v2f_basemap {
				float4 pos: POSITION; 
				float4 uv[3] : TEXCOORD0;
			};
			v2f_basemap vert (appdata_basemap v) 
			{
				v2f_basemap o;
				#ifdef SHADER_API_D3D9
				float2 scaled_uv = v.texcoord * float2(2,-2) + float2(-1,1);
				#else
				float2 scaled_uv = v.texcoord * 2 + float2(-1,-1) + (v.vertex.w - 1) * 0.000001;
				#endif
				o.pos = float4( scaled_uv.x,scaled_uv.y,0, 1);
	
				CALC_SPLAT_UV(v.texcoord.xy, v.texcoord1.xy);

				return o;
			}
			
			float4 frag (v2f_basemap i) : COLOR {
				half4 splat;
				SAMPLE_SPLAT(i,splat);
				half4 col = splat * tex2D (_LightMap, i.uv[0].zw);
				col *= float4 (2,2,2,0);
				return float4(col.rgb,1);
			}
		
			ENDCG
		}
		
	}
	Fallback Off 
}