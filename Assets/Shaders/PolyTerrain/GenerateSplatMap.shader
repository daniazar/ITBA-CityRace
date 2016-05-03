Shader "PolyTerrain/Splatmap/GenerateSplatMap" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_UpDirection ("Up Direction", Vector) = (0,	1, 0,0)
		_RangeMin ("Range Midpoints", Vector) = ( 0, 0.2, .9, .95 )
		_RangeMax ("Range Midpoints", Vector) = ( .2, 0.3, 0.95, 1 )
		_HeightOffset ("Height Offset", Float) = 0
		_AnglePerHeight ("Angle increase per 1 m height", Float) = 0
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
			#pragma fragment frag
			#pragma fragmentoption ARB_fog_exp2
			#pragma fragmentoption ARB_precision_hint_fastest
	
			uniform float4 _UpDirection;
			//uniform float4 _Midpoints;
			uniform float4 _RangeMin;
			uniform float4 _RangeMax;
			
			uniform float _HeightOffset;
			uniform float _AnglePerHeight;
	
			struct appdata_base {
		    	float4 vertex : POSITION;
		    	float3 normal : NORMAL;
		    	float2 texcoord : TEXCOORD0;
			};
		
			struct v2f
			{
				float4 pos : POSITION;
				float3 norm ;
				float heightangle;
			};
		
			v2f vert ( appdata_base v )
			{
				v2f o;
				#ifdef SHADER_API_D3D9
				float2 scaled_uv = v.texcoord * float2(2,-2) + float2(-1,1);
				#else
				float2 scaled_uv = v.texcoord * 2 + float2(-1,-1);
				#endif
				o.pos = float4( scaled_uv.x,scaled_uv.y,0, 1); 
				//o.pos = v.vertex;

				o.norm = v.normal;
				o.heightangle =( dot(_UpDirection.xyz, v.vertex.xyz) + _HeightOffset )* _AnglePerHeight;
				return o;
			} 
			


			float4 rangelerp( float range, float4 minrange, float4 maxrange )
			{
				float4 range_comp = float4( range, range, range, range );
				float4 prevmax = float4(-2, maxrange.xyz);
				float4 nextmin = float4(minrange.yzw, 3);
				float4 lerp_up = (range_comp - prevmax) / (minrange - prevmax);
				float4 lerp_down = (nextmin - range_comp) / (nextmin - maxrange);
				float4 lerp_Val = (range_comp < minrange) ? lerp_up : float4(1,1,1,1);
				lerp_Val = (range_comp > maxrange) ? lerp_down : lerp_Val;
				lerp_Val = saturate(lerp_Val);
				float sumVal = dot(float4(1,1,1,1), lerp_Val); // Sum normalization
				lerp_Val = lerp_Val / sumVal;
				return lerp_Val;
			}

			 
			float4 frag( v2f i ) : COLOR
			{
				float3 renorm = normalize( i.norm );
			//	float4 color = float4(i.norm, 0);
				float range = acos(dot(renorm, _UpDirection.xyz )) + i.heightangle;
			//	float4 color = fourlerp( range, _Midpoints);
				float4 color = rangelerp( range, _RangeMin, _RangeMax );

				return color;
			}
			ENDCG
		}
	}
	Fallback Off 
}