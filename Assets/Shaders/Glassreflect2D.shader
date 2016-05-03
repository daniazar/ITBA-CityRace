Shader "Car/Glassreflect2D" {
Properties {
	_MainTex ("Base (RGB reflection)", 2D) = "black" {}
	_Color ("Main Color", Color) = (1,1,1,1)
	_BumpMap ("Bumpmap (RGB Trans)", 2D) = "bump" {}
	_Cube ("Reflection Cubemap", Cube) = "" { TexGen CubeReflect }
	_ReflectInShadow("Reflect in shadow",Range( 0, 1)) = 0.2
	_LightMap("Lightmap (RGB)", 2D) = "grey" {}
	_LightmapDensity("Lightmap Density",Range( 0, 1)) = 0.5	
	_2DReflection ("Reflection (RGB)", 2D) = "grey" {}
	_ReflectionColor ("Reflection Color", Color) = ( 0.5, 0.5, 0.5, 1)
}

Category {
	Tags { Queue = Transparent }
	Blend SrcAlpha OneMinusSrcAlpha
	Lighting Off
	Colormask RGB

	// ---- fragment program cards
	SubShader {
		Pass {
			
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest 
#include "UnityCG.cginc"

struct v2f {
	V2F_POS_FOG;
	float2  uv[3];
	float3	viewDir;
	float3 TtoW0;
	float3 TtoW1;
	float3 TtoW2;
};

uniform float4 _MainTex_ST;
uniform float4 _BumpMap_ST;
uniform matrix _LightmapMatrix;

v2f vert (appdata_tan v)
{	
	v2f o;
	PositionFog( v.vertex, o.pos, o.fog );
	o.uv[0] = TRANSFORM_TEX(v.texcoord, _MainTex);
	o.uv[1] = TRANSFORM_TEX( v.texcoord, _BumpMap );
	o.uv[2] = mul(_LightmapMatrix, v.vertex).xy;
	
	o.viewDir = normalize(mul( (float3x3)_Object2World, ObjSpaceViewDir(v.vertex) ));
	
	TANGENT_SPACE_ROTATION;
	o.TtoW0 = mul(rotation, _Object2World[0].xyz);
	o.TtoW1 = mul(rotation, _Object2World[1].xyz);
	o.TtoW2 = mul(rotation, _Object2World[2].xyz);

	return o;
}

uniform samplerCUBE _Cube;
uniform float4 _Color;
uniform sampler2D _MainTex;
uniform sampler2D _BumpMap;
uniform sampler2D _LightMap;
uniform sampler2D _2DReflection;
uniform float4 _ReflectionColor;

uniform float _LightmapDensity;
uniform float _ReflectInShadow;
uniform matrix _2DReflectionMatrix;

float4 frag (v2f i)  : COLOR
{
	float4 bump = tex2D(_BumpMap, i.uv[1] );
	
	float3 normal = bump.xyz * 2 - 1;
	// transform normal to world space
	half3 wn;
	wn.x = dot(i.TtoW0, normal);
	wn.y = dot(i.TtoW1, normal);
	wn.z = dot(i.TtoW2, normal);

	i.viewDir = normalize(i.viewDir);
	half nsv = saturate(dot( wn, i.viewDir ));
	
	// calculate reflection vector in world space
	half3 r = reflect(-i.viewDir, wn);
	
	half4 mainColor = tex2D(_MainTex, i.uv[0]);

	float3 reflectUVW = mul((float3x3)_2DReflectionMatrix, r).xyz;
	reflectUVW = normalize(reflectUVW);	
	reflectUVW.xy = normalize( reflectUVW.xy ) * acos(  reflectUVW.z) 
		 * 0.1591 + 0.5; // 0.5 / PI  for normalization
	half4 reflcolor = tex2D(_2DReflection, reflectUVW.xy ); 

	half fresnel = 1 - nsv *0.5;
	half fresnelAlpha = 1 - nsv * (1 - bump.a);
	half4 c = half4( lerp( _Color.rgb, reflcolor.rgb, fresnel ), fresnelAlpha );
	
	half4 lightmapColor = tex2D(_LightMap, i.uv[2]);
	half light = (Luminance(lightmapColor.rgb) * _LightmapDensity);
	c.rgb *= (_ReflectionColor.rgb * mainColor.a);
	c = c + half4(mainColor.rgb * bump.a, 0) * light;
	
	return c;
}
ENDCG  
		}
	}
	
	// ---- cards that can do cube maps
	SubShader {
		Pass {
			SetTexture [_Cube] { matrix[_RotMatrix] constantColor(1,1,1,0.5) combine texture, constant }
		}
	}
	
	// ---- cards that can't do anything
	SubShader {
		Pass {
			Color (1,1,1,0.3)
		}
	}
}

}
