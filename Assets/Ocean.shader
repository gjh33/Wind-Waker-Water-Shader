// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Water/Ocean"
{
	Properties
	{
		_OceanMask ("Ocean Mask", 2D) = "black" {}
		_Tint("Tint", Color) = (0.2, 0.2, 1, 0)
		_WaveHeight("Wave Height", float) = 1.5
		_SmoothShading("Smooth Shading", float) = 4
		_WaveSpeed("Wave Speed", float) = 0.5
		_WaveLength("Wave Length", float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 world_position : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _OceanMask;
			float4 _OceanMask_ST;
			float4 _Tint;
			float _WaveHeight;
			float _SmoothShading;
			float _WaveSpeed;
			float _WaveLength;
			
			v2f vert (appdata v)
			{
				v2f o;
				float3 _WorldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
				float2 _WaveOffset = (_WorldPosition.xz * _WaveLength) + (_Time[1] * _WaveSpeed);
				v.vertex.xyz += v.normal * _WaveHeight * ((sin(_WaveOffset[0]) + sin(_WaveOffset[1]) + sin(_WaveOffset[0] * 2) + sin(_WaveOffset[1] * 3 + _WaveOffset[0]))/4);
				o.color.xyz = _Tint.xyz * ((1-(0.5/_SmoothShading)) + (sin(_WaveOffset[0]) + sin(_WaveOffset[1]) + sin(_WaveOffset[0] * 2) + sin(_WaveOffset[1] * 3 + _WaveOffset[0]))/(4 * 2 * _SmoothShading));
				o.color.a = 0;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _OceanMask);
				o.world_position = _WorldPosition.xz;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float _XCoord = 0.07 * (sin(i.world_position.y * 4.0 / 100 + _Time[1] * 0.5) + sin(i.world_position.y * 6.8 / 100 + _Time[1] * 0.75) + sin(i.world_position.y / 100 * 11.3 + _Time[1] * 0.2)) / 3;
				float _YCoord = 0.07 * (sin(i.world_position.x * 3.5 / 100 + _Time[1] * 0.35) + sin(i.world_position.x * 4.8 / 100 + _Time[1] * 1.05) + sin(i.world_position.x / 100 * 7.3 + _Time[1] * 0.45)) / 3;
				float2 _SampleUV = i.uv + float2(_XCoord, _YCoord);
				fixed4 col = tex2D(_OceanMask, _SampleUV);
				col = col + i.color;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
