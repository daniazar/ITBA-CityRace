Shader "PolyTerrain/Splatmap/Lightmap-BaseMap" {
Properties {
	_LightMap ("LightMap (RGB)", 2D) = "white" {}
	_BaseMap ("BaseMap (RGB)", 2D) = "white" {}
}

// dual texture cards
SubShader {
	Tags {
		"SplatCount" = "0"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
	Pass {
		Tags { "LightMode" = "Always" }
		BindChannels {
			Bind "Vertex", vertex
			Bind "normal", normal
			Bind "texcoord", texcoord0 // main uses 1st uv
			Bind "texcoord1", texcoord1 // lightmap uses 2nd uv
		}

		SetTexture [_BaseMap] { combine texture }
		SetTexture [_LightMap] { combine texture * previous DOUBLE }
	}
	UsePass "VertexLit/SHADOWCASTER"
}

// single texture cards, draw in two passes
SubShader {
	Tags {
		"SplatCount" = "0"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
	Pass {
		Tags { "LightMode" = "Always" }
		SetTexture [_BaseMap] { combine texture }
	}
	Pass {
		Tags { "LightMode" = "Always" }
		BindChannels {
			Bind "Vertex", vertex
			Bind "normal", normal
			Bind "texcoord1", texcoord0 // lightmap uses 2nd uv
		}
		Blend DstColor SrcColor
		ZWrite Off
		SetTexture [_LightMap] { combine texture }
	}
}

// single texture cards that don't support multiplicative blends - no lightmap :(
SubShader {
	Tags {
		"SplatCount" = "0"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
	Pass {
		Tags { "LightMode" = "Always" }
		SetTexture [_BaseMap] { combine texture }
	}
}
}
