﻿Shader "Custom/Hologram_Scanlines"
{
	//this shader was created by Jonathan Gonzalez
	//the original project can be found here https://github.com/jgonzosan
	
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainColor("Color Tint", Color) = (1,1,1,1)
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimPower("Rim Power", Range(0,3)) = 1
		_RimBrightness("Rim Brightness", Range(0, 3)) = 1
		_Alpha("Alpha", Range(0,1)) = 0.5
		_ScanlineScale("Scanline Scale", Range(0,100)) = 0
		_ScanlineSpeed("Scanline Speed", Range(0,50)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
					
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldVertex : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float3 worldNormal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainColor;
			float4 _RimColor; 
			half _RimPower;
			half _RimBrightness;
			fixed _Alpha;
			half _ScanlineScale;
			half _ScanlineSpeed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldVertex = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldVertex.xyz));			
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float scan = step(frac(i.worldVertex.y * _ScanlineScale + _Time.y *_ScanlineSpeed), .75);
				float bigScanline = frac(i.worldVertex.y - _Time.x * 10);


				fixed4 tex = tex2D(_MainTex, i.uv);
				half rim = 1 - saturate(dot(i.viewDir, i.worldNormal));
				fixed4 rimColor = _RimColor * pow(rim, _RimPower);
				fixed4 col = tex * _MainColor +(bigScanline * 0.5 * _MainColor) + rimColor;
				col.a = _Alpha * scan;
				col.rgb *= _RimBrightness;
				return col;
			}
			ENDCG
		}
	}
}
