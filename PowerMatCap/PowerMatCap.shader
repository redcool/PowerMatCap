Shader "Unlit/PowerMatCap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Toggle]_NormalMapOn("_NormalMapOn",int) = 0
        _NormalMap("_NormalMap",2d) = "bump"{}
        _DetailNormalMap("_DetailNormalMap",2d) = "bump"{}

        _MatCap("_MatCap",2d) =""{}
        _MatCapIntensity("_MatCapIntensity",float) = 1

        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        pass{
            colorMask 0
        }

        Pass
        {
            Blend [_SrcMode][_DstMode]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "../Lib/TangentLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                TANGENT_SPACE_DECLARE(2,3,4);
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            bool _NormalMapOn;
            sampler2D _NormalMap;
            sampler2D _DetailNormalMap;

            sampler2D _MatCap;
            float _MatCapIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                TANGENT_SPACE_COMBINE(v.vertex,v.normal,v.tangent,o/**/);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                TANGENT_SPACE_SPLIT(i);

                float3 n = normal;
                if(_NormalMapOn){
                    float3 tn = UnpackNormal(tex2D(_NormalMap,i.uv));
                    float3 detailTN = UnpackNormal(tex2D(_DetailNormalMap,i.uv));
                    tn = float3(tn.xy + detailTN.xy,tn.z * detailTN.z);

                    n = TangentToWorld(i.tSpace0,i.tSpace1,i.tSpace2,tn);
                }

                float2 matUV = mul(UNITY_MATRIX_V,n).xy * 0.5 + 0.5;
                
                float4 mat = tex2D(_MatCap,matUV);
                mat.rgb *=  _MatCapIntensity;
                
                float nl = dot(normal,_WorldSpaceLightPos0) * 0.5 + 0.5;
                nl = smoothstep(0,1.5,nl);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // col.rgb *= nl;
                col.rgb = (col+mat) * nl;
                col.a = mat.a;
                // col.rgb +=lerp(col,  mat, 0.5);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
