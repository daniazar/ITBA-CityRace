Shader "Car new/Car diffusebumpfresnelreflect2D" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,0)
	_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
	_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
	_ReflectInShadow("Reflect in shadow",Range( 0, 1)) = 0.2
	_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
	_BumpMap ("Bumpmap (RGB)", 2D) = "bump" {}
	_LightMap ("Lightmap (RGB)", 2D) = "grey" {}
	_LightmapDensity("Lightmap Density",Range( 0, 1)) = 0.5
	_2DReflection ("Reflection (RGB)", 2D) = "grey" {}
	_Cube ("Reflection Cubemap", Cube) = "" { TexGen CubeReflect }

	_FresnelColor ("Fresnel Color", Color) = (1,1,1,0)
	_FresnelRamp ("Fresnel Ramp (RGB)", 2D) = "white" {} 

	_SparkleTex ("Sparkle noise (RGB)", 2D) = "white" {}
	_Sparkle ("Sparkle strength 1", Range(0, 0.3)) = 0.1
	_SparkleDensity("Sparkle Density",Range(0.001,0.3)) = 0.02
	_SparkleColor ("Sparkle Color", Color) = (1,1,1,1)
	_SparkleHardness("Sparkle Hardness", Range(1,128)) = 32
	_HardEdge("Hard Edge", Range(0,16)) = 0.1
}

// ---- fragment program cards: everything
SubShader { 
	Pass {
		Name "PPL"	

		Tags { "LightMode"="Pixel"}
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_builtin
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest 
#include "UnityCG.cginc"
#include "AutoLight.cginc" 



struct v2f {
	V2F_POS_FOG;
	LIGHTING_COORDS
	float2	uv[4];
	float3	viewDirT;
	float3  lightDirT;
};

struct appdata_tan2 {
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float2 texcoord : TEXCOORD0;
    float2 texcoord1 : TEXCOORD1;
};

uniform float _Shininess;
uniform float4 _MainTex_ST;
uniform float4 _BumpMap_ST;
uniform float4 _SparkleTex_ST;
uniform matrix _LightmapMatrix;

v2f vert (appdata_tan2 v)
{	
	v2f o;
	PositionFog( v.vertex, o.pos, o.fog );
	o.uv[0] = TRANSFORM_TEX( v.texcoord, _MainTex );
	o.uv[1] = TRANSFORM_TEX( v.texcoord, _BumpMap );
	o.uv[2] = TRANSFORM_TEX( v.texcoord, _SparkleTex );
	
	o.uv[3] = mul(_LightmapMatrix, v.vertex).xy;
	
	TANGENT_SPACE_ROTATION;
	o.viewDirT = mul( rotation, ObjSpaceViewDir( v.vertex ) );	
	o.lightDirT = mul( rotation, ObjSpaceLightDir( v.vertex ) );	
	
	TRANSFER_VERTEX_TO_FRAGMENT(o);	
	return o;
}

uniform sampler2D _MainTex;
uniform sampler2D _BumpMap;
uniform sampler2D _LightMap;
uniform sampler2D _SparkleTex;
uniform sampler2D _FresnelRamp;
uniform samplerCUBE _Cube;
uniform float _Sparkle;
uniform float4 _Color;
uniform float4 _FresnelColor;
uniform float4 _SparkleColor;
uniform float4 _SpecColor;
uniform float4 _ReflectColor;
uniform float _SparkleDensity;
uniform float _SparkleHardness;
uniform float _ReflectInShadow;
uniform float _LightmapDensity;
uniform float _HardEdge;

float4 frag (v2f i)  : COLOR
{
	half4 normalVal  = tex2D(_BumpMap, i.uv[1]);
	half3 normal = normalVal.xyz * 2 -1;
	half4 noiseSample = tex2D( _SparkleTex, i.uv[2] );
	half3 normalN = noiseSample.xyz * 2 - 1;

//	normalN = normalize( normalN );
	 
	half3 perturbnormal1 = normalize(lerp( normal, normalN, _Sparkle ));
	
	i.viewDirT = normalize(i.viewDirT);
	
	float fresnelSparkle1 = saturate( dot( perturbnormal1, i.viewDirT));
	
	float fressq = fresnelSparkle1 * fresnelSparkle1;
	half4 duotone = _FresnelColor * tex2D(_FresnelRamp, float2(fressq,0.5) );
	half4 mainColor = tex2D( _MainTex, i.uv[0] );
	
	half4 lightmapColor = tex2D(_LightMap, i.uv[3]);
	half lightMap = Luminance(lightmapColor.rgb) * _LightmapDensity;
	half light =  min( saturate(i.lightDirT.z * _HardEdge), LIGHT_ATTENUATION(i)) * lightMap;
	half d = light * (dot( perturbnormal1, normalize(i.lightDirT)));
	duotone +=  _ModelLightColor0 * mainColor;
	
	duotone *= d * 2; 
	duotone += mainColor * (_PPLAmbient + lightMap);
	half4 c =  half4(duotone.rgb, light + _ReflectInShadow );

	return c;
}
ENDCG  
	}
	
	Pass {
		Name "REFLECTION"	

		Tags { "LightMode"="Pixel"}
//		Blend DstAlpha One
		Blend One One
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest 
#include "UnityCG.cginc"
//#include "AutoLightCustom.cginc"  
#include "AutoLight.cginc" 

struct v2f {
	V2F_POS_FOG;
	float2	uv[2];
	float3	viewDir;
	float3	TtoW0;
	float3	TtoW1;
	float3	TtoW2;
};

struct appdata_tan2 {
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float2 texcoord : TEXCOORD0;
};

uniform float _Shininess;
uniform float4 _SparkleTex_ST;
uniform float4 _MainTex_ST;
uniform float4 _BumpMap_ST;

v2f vert (appdata_tan2 v)
{	
	v2f o;
	PositionFog( v.vertex, o.pos, o.fog );
	o.uv[0] = TRANSFORM_TEX( v.texcoord, _MainTex );
	o.uv[1] = TRANSFORM_TEX( v.texcoord, _BumpMap );
	
	o.viewDir = normalize(mul( (float3x3)_Object2World, ObjSpaceViewDir( v.vertex )));	
	
	TANGENT_SPACE_ROTATION;
	o.TtoW0 = mul(rotation, _Object2World[0].xyz);
	o.TtoW1 = mul(rotation, _Object2World[1].xyz);
	o.TtoW2 = mul(rotation, _Object2World[2].xyz);
	
	return o;
}

uniform sampler2D _MainTex;
uniform sampler2D _BumpMap;
uniform sampler2D _2DReflection;
uniform float4 _SpecColor;
uniform float4 _ReflectColor;
uniform matrix _2DReflectionMatrix;

float4 frag (v2f i)  : COLOR
{
	half specMap = tex2D(_MainTex, i.uv[0]).a;
	half4 normalVal  = tex2D(_BumpMap, i.uv[1]);
	half3 normal = normalVal.xyz * 2 -1;

	// transform normal to world space
	half3 wn;
	wn.x = dot(i.TtoW0, normal);
	wn.y = dot(i.TtoW1, normal);
	wn.z = dot(i.TtoW2, normal);
	
	// calculate reflection vector in world space
	
	half3 r = reflect(-i.viewDir, wn);
	
	float3 reflectUVW = mul((float3x3)_2DReflectionMatrix, r).xyz;
	reflectUVW = normalize(reflectUVW);	
	reflectUVW.xy = normalize( reflectUVW.xy ) * acos(  reflectUVW.z) 
		 * 0.1591 + 0.5; // 0.5 / PI  for normalization
	half4 reflcolor = tex2D(_2DReflection, reflectUVW.xy ); 
	
//	half nsv = saturate(dot( normal, i.viewDirT ));
	half nsv = saturate(dot( wn, i.viewDir ));

	half fresnel = 1 - nsv * 0.5;
	half4 c =  specMap * reflcolor * _ReflectColor * 2 * fresnel;
	//+ half4(zfac, 0,0,0) ;
	
	return c;
}
ENDCG  
	}
		
	
}
FallBack  "Reflective/Bumped Specular", 0

}
