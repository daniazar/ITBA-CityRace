
#include "UnityCG.cginc"
#include "AutoLight.cginc" 


// Calculates Blinn-Phong (specular) lighting model, but omits glow
inline half4 SpecularLightNoGlow( half3 lightDir, half3 viewDir, half3 normal, half4 color, float speccol, float specK, half atten )
{
	#ifndef USING_DIRECTIONAL_LIGHT
	lightDir = normalize(lightDir);
	#endif
	viewDir = normalize(viewDir);
	half3 h = normalize( lightDir + viewDir );
	
	half diffuse = dot( normal, lightDir );
	
	float nh = saturate( dot( h, normal ) );
	float spec = pow( nh, specK ) * speccol;
	
	half4 c;
	c.rgb = (color.rgb * _ModelLightColor0.rgb * diffuse + _SpecularLightColor0.rgb * spec) * (atten * 2);
	c.a = color.a; // alpha used for blending
	return c;
}

// Calculates Blinn-Phong (specular) only the glow
inline half4 SpecularLightGlow( half3 lightDir, half3 viewDir, half3 normal, float color, float speccol, float specK, half atten )
{
	#ifndef USING_DIRECTIONAL_LIGHT
	lightDir = normalize(lightDir);
	#endif
	viewDir = normalize(viewDir);
	half3 h = normalize( lightDir + viewDir );
	
	float nh = saturate( dot( h, normal ) );
	float spec = pow( nh, specK ) * _SpecularLightColor0.a;

	half4 c;
	c.rgb = half3(0,0,0);
	c.a = spec * atten * speccol * color; 
	return c;
}


uniform sampler2D _MainTex;
uniform sampler2D _SpecMap;

struct v2f_alpha_vertex_lit {
	float2 uv	: TEXCOORD0;
	float2 uv2	: TEXCOORD1;
	float4 diff	: COLOR0;
	float4 spec	: COLOR1;
};  


half4 vertex_frag (v2f_alpha_vertex_lit i) : COLOR {
	half4 texcol = tex2D( _MainTex, i.uv );
	half4 speccol = tex2D( _SpecMap, i.uv2 );
	half4 c;
	c.rgb = ( texcol.rgb * i.diff.rgb + i.spec.rgb * speccol.a ) * 2;
	c.a = texcol.a * i.diff.a;
	return c;
} 

struct v2f_alpha_vertex_lit_glow {
	float2 uv	: TEXCOORD0;
	float2 uv2	: TEXCOORD1;
	float4 spec	: COLOR1;
};  


half4 vertex_frag_glow (v2f_alpha_vertex_lit_glow i) : COLOR {
	half4 texcol = tex2D( _MainTex, i.uv );
	half4 speccol = tex2D( _SpecMap, i.uv2 );
	half4 c;
	c.rgb = half3(0,0,0);
	c.a = i.spec.a * speccol.a * texcol.a;
	return c;
} 


#ifdef PIXEL_PASS_SPECULAR

struct v2f_alpha_pixel_spec {
	V2F_POS_FOG;
	LIGHTING_COORDS
	float3	uvK; // xy = UV, z = specular K
	float2	uv2;
	float3 normal;
	float3	viewDirT;
	float3	lightDirT;
}; 

uniform float4 _MainTex_ST;
uniform float4 _SpecMap_ST;
uniform float _Shininess;

v2f_alpha_pixel_spec vert_pixel_specular (appdata_tan v)
{	
	v2f_alpha_pixel_spec o;
	PositionFog( v.vertex, o.pos, o.fog );
	o.uvK.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
	o.uvK.z = _Shininess * 128;
	o.uv2 = TRANSFORM_TEX(v.texcoord, _SpecMap);

	o.normal = v.normal;
	o.lightDirT = ObjSpaceLightDir( v.vertex );	
	o.viewDirT =  ObjSpaceViewDir( v.vertex );	

	TRANSFER_VERTEX_TO_FRAGMENT(o);	
	return o;
}


float4 frag_pixel_specular (v2f_alpha_pixel_spec i) : COLOR
{		
	float4 texcol = tex2D( _MainTex, i.uvK.xy );
	half4 speccol = tex2D( _SpecMap, i.uv2 );
	
	half4 c = SpecularLightNoGlow( i.lightDirT, i.viewDirT, i.normal, texcol, speccol.a,i.uvK.z, LIGHT_ATTENUATION(i) );
	return c;
}

#endif // PIXEL_PASS_SPECULAR

#ifdef PIXEL_PASS_SPECULAR_GLOW

struct v2f_alpha_pixel_spec_glow {
	V2F_POS_FOG;
	LIGHTING_COORDS
	float2 uvK; //float3	uvK; // xy = UV, z = specular K
	float2	uv2;
//	float3 normal;
//	float3	viewDirT;
//	float3	lightDirT;
}; 

uniform float4 _MainTex_ST;
uniform float4 _SpecMap_ST;
uniform float _Shininess;

v2f_alpha_pixel_spec_glow vert_pixel_specular_glow (appdata_tan v)
{	
	v2f_alpha_pixel_spec_glow o;
	PositionFog( v.vertex, o.pos, o.fog );
	o.uvK.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
//	o.uvK.z = _Shininess * 128;
	o.uv2 = TRANSFORM_TEX(v.texcoord, _SpecMap);

//	o.normal = v.normal;
//	o.lightDirT = ObjSpaceLightDir( v.vertex );	
//	o.viewDirT =  ObjSpaceViewDir( v.vertex );	

	TRANSFER_VERTEX_TO_FRAGMENT(o);	
	return o;
}


float4 frag_pixel_specular_glow (v2f_alpha_pixel_spec_glow i) : COLOR
{		
	float4 texcol = tex2D( _MainTex, i.uvK.xy );
	half4 speccol = tex2D( _SpecMap, i.uv2 );
	
	//half4 c = SpecularLightGlow( i.lightDirT, i.viewDirT, i.normal, texcol.a, speccol.a,i.uvK.z, LIGHT_ATTENUATION(i) );
	half4 c = half4(0,0,0,0);
	c.a = _SpecularLightColor0.a * speccol.a * texcol.a * LIGHT_ATTENUATION(i);
	return c;
}

#endif // PIXEL_PASS_SPECULAR_GLOW

















/*
inline half4 VertexLight( v2f_vertex_lit i, sampler2D mainTex )
{
	half4 texcol = tex2D( mainTex, i.uv );
	half4 c;
	c.xyz = ( texcol.xyz * i.diff.xyz + i.spec.xyz * texcol.a ) * 2;
	c.w = texcol.w * i.diff.w;
	return c;
}
*/

/*

		Pass {
			Name "BASE"
			Tags {"LightMode" = "PixelOrNone"}
			Blend AppSrcAdd AppDstAdd
			Color [_PPLAmbient]
			SetTexture [_MainTex] {constantColor [_Color] Combine texture * primary DOUBLE, texture *  constant}
		}
		// Vertex lights
		Pass {
			Name "BASE"
			Tags {"LightMode" = "Vertex"}
			Lighting On
			Material {
				Diffuse [_Color]
				Emission [_PPLAmbient]
				Specular [_SpecColor]
				Shininess [_Shininess]
			}
			SeparateSpecular On

CGPROGRAM
#pragma fragment frag
#pragma fragmentoption ARB_fog_exp2
#pragma fragmentoption ARB_precision_hint_fastest

#include "UnityCG.cginc"

uniform sampler2D _MainTex;

half4 frag (v2f_vertex_lit i) : COLOR {
	return VertexLight( i, _MainTex );
} 
ENDCG
		}





struct v2f {
	float4 pos : POSITION;
	float fog : FOGC;
	float4 uv : TEXCOORD0;
	float4 color : COLOR0;
};

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
	float3	uvK; // xy = UV, z = specular K
	float2	uv2;
	flaot3 normal;
	float3	viewDirT;
	float3	lightDirT;
}; 

uniform float4 _MainTex_ST, _BumpMap_ST;
uniform float _Shininess;

v2f vert (appdata_tan v)
{	
	v2f o;
	PositionFog( v.vertex, o.pos, o.fog );
	o.normal = v.normal;
	o.uvK.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
	o.uvK.z = _Shininess * 128;
	o.uv2 = TRANSFORM_TEX(v.texcoord, _BumpMap);

	TANGENT_SPACE_ROTATION;
	o.lightDirT = mul( rotation, ObjSpaceLightDir( v.vertex ) );	
	o.viewDirT = mul( rotation, ObjSpaceViewDir( v.vertex ) );	

	TRANSFER_VERTEX_TO_FRAGMENT(o);	
	return o;
}

uniform sampler2D _BumpMap;
uniform sampler2D _MainTex;

float4 frag (v2f i) : COLOR
{		
	float4 texcol = tex2D( _MainTex, i.uvK.xy );
	
	half4 c = SpecularLight( i.lightDirT, i.viewDirT, i.normal, texcol, i.uvK.z, LIGHT_ATTENUATION(i) );
	return c;
}
*/
/*

v2f hair(appdata v) {
	v2f o;
	// Calc vertex position
	float4 vertex = v.vertex * _Scale;
	float4 bent = mul(_TerrainEngineBendTree, vertex);
	vertex = lerp(vertex, bent, v.color.w);
	vertex.w = 1;
	
	o.pos = mul(glstate.matrix.mvp, vertex);
	o.fog = o.pos.z;
	o.uv = v.texcoord;
	
	float4 lightDir;
	lightDir.w = _AO;

	float4 lightColor = glstate.lightmodel.ambient;
	for (int i = 0; i < 4; i++) {
		#ifdef USE_CUSTOM_LIGHT_DIR
		lightDir.xyz = _TerrainTreeLightDirections[i];
		#else
		lightDir.xyz = mul ( glstate.light[i].position.xyz, (float3x3)glstate.matrix.invtrans.modelview[0]);
		#endif

		lightDir.xyz *= _Occlusion;
		float occ =  dot (v.tangent, lightDir);
		occ = max(0, occ);
		occ += _BaseLight;
		lightColor += glstate.light[i].diffuse * occ;
	}

	lightColor.a = 1;
//	lightColor = saturate(lightColor);
	
	o.color = lightColor * _Color;
	#ifdef WRITE_ALPHA_1
	o.color.a = 1;
	#endif
	return o; 
}

*/
