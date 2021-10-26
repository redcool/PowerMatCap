Shader "PowerXXX/PowerMatcap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("_Color",color)=(1,1,1,1)

        [Toggle]_NormalMapOn("_NormalMapOn",float) = 0
        _NormalMap("_NormalMap",2d)= ""{}
        _NormalScale("_NormalScale",range(0,10)) = 1

        _DetailNormalMap("_DetailNormalMap",2d)=""{}
        _DetailNormalScale("_DetailNormalScale",range(0,10)) = 1

        _MatCap("_MatCap",2d)=""{}
        _MatCapScale("_MatCapScale",float) = 1
        _MatCapMask("_MatCapMask",2d) = "white"{}

        [Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Blend [_SrcMode][_DstMode]
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityStandardUtils.cginc"
            #include "Lib/TangentLib.cginc"

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
            float4 _Color;

            float _NormalMapOn;
            sampler2D _NormalMap;
            float _NormalScale;
            float4 _NormalMap_ST;

            sampler2D _DetailNormalMap;
            float _DetailNormalScale;
            float4 _DetailNormalMap_ST;

            sampler2D _MatCap;
            float _MatCapScale;
            sampler2D _MatCapMask;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                TANGENT_SPACE_COMBINE(v.vertex,v.normal,v.tangent,o/**/);

                return o;
            }

            float4 CalcMatCap(float3 normal){
                float3 normalView = mul(UNITY_MATRIX_V,normal);
                normalView = normalView*0.5+0.5;

                float2 matUV = (normalView.xy);
                float4 matCap = tex2D(_MatCap,matUV);
                return matCap * _MatCapScale;
            }

            float3 TrangentToWorld(float3 tn,float3 tSpace0,float3 tSpace1,float3 tSpace2){
                return normalize(float3(
                    dot(tSpace0.xyz,tn),
                    dot(tSpace1.xyz,tn),
                    dot(tSpace2.xyz,tn)
                ));
            }

            float3 CalcNormal(sampler2D map,float2 uv,float scale,float3 tSpace0,float3 tSpace1,float3 tSpace2){
                float3 tn = UnpackScaleNormal(tex2D(_NormalMap,uv),scale);
                float3 normal = TrangentToWorld(tn,tSpace0.xyz,tSpace1.xyz,tSpace2.xyz);
                return normal;
            }

            float3 BlendNormal(float3 a,float3 b){
                return normalize(float3(a.xy*b.xy,a.z+b.z));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                TANGENT_SPACE_SPLIT(i);
                
                if(_NormalMapOn){
                    float2 normalUV = i.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
                    float2 detailUV = i.uv *  _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;

                    float3 tn = UnpackScaleNormal(tex2D(_NormalMap,i.uv),_NormalScale);
                    float3 detailTN = UnpackScaleNormal(tex2D(_DetailNormalMap,i.uv),_NormalScale);
                    tn = float3(tn.xy + detailTN.xy,tn.z * detailTN.z);

                    tn = BlendNormal(tn,detailTN);
                    normal = TangentToWorld(i.tSpace0,i.tSpace1,i.tSpace2,tn);
                }
                
                float nl = dot(_WorldSpaceLightPos0.xyz,normal) * 0.5+0.5;;
                float4 matCap = CalcMatCap(normal);

                float matCapMask = tex2D(_MatCapMask,i.uv).x;

                // return matCap;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                col.xyz = (col.xyz + (matCap.xyz * matCapMask)) * nl;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}

