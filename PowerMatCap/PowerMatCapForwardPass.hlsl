#if !defined(POWER_MATCAP_FORWARD_PASS_HLSL)
#define POWER_MATCAP_FORWARD_PASS_HLSL


#include "Lib/UnityLib.hlsl"
#include "Lib/TangentLib.cginc"
#include "Lib/PowerMatcapInput.cginc"

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
    float4 vertex : SV_POSITION;

    TANGENT_SPACE_DECLARE(2,3,4);
    float3 reflectDir:TEXCOORD5;
};

v2f vert (appdata v)
{
    v2f o;
    o.vertex = TransformObjectToHClip(v.vertex.xyz);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    TANGENT_SPACE_COMBINE(v.vertex,v.normal,v.tangent,o/**/);

    float3 worldView = GetWorldSpaceViewDir(p);
    o.reflectDir = TransformObjectToWorldDir(worldView+_EnvMapOffset);
    return o;
}

float4 CalcMatCap(float3 normal){
    float3 normalView = mul(UNITY_MATRIX_V,normal);
    normalView = normalView*0.5+0.5;

    float2 matUV = (normalView.xy);
    float4 matCap = tex2D(_MatCap,matUV);
    return matCap;
}

float3 BlendNormal(float3 a,float3 b){
    return normalize(float3(a.xy*b.xy,a.z+b.z));
}

float3 CalcIbl(samplerCUBE cubemap,float rough,float3 reflectDir){
    rough = rough *(1.7 - rough * 0.7);
    float mip = rough * 6; 
    float4 cubeCol = texCUBElod(cubemap,float4(reflectDir,mip));
    return DecodeHDREnvironment(cubeCol,unity_SpecCube0_HDR);
}

half4 frag (v2f input) : SV_Target
{
    TANGENT_SPACE_SPLIT(input);
    
    if(_NormalMapOn){
        float2 normalUV = input.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
        float2 detailUV = input.uv *  _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;

        float3 tn = UnpackNormalScale(tex2D(_NormalMap,input.uv),_NormalScale);
        float3 detailTN = UnpackNormalScale(tex2D(_DetailNormalMap,input.uv),_DetailNormalScale);
        tn = float3(tn.xy + detailTN.xy,tn.z * detailTN.z);

        tn = BlendNormal(tn,detailTN);
        normal = TangentToWorld(input.tSpace0,input.tSpace1,input.tSpace2,tn);
    }
    
    float wnl = dot(_WorldSpaceLightPos0.xyz,normal) * 0.5+0.5;;
    float4 matCap = CalcMatCap(normal) * _MatCapScale;

    // mask
    float4 maskTex = tex2D(_EnvMask,input.uv);
    float matCapMask = maskTex.x;
    float iblMask = maskTex.y;

    float a = _Roughness * _Roughness;
    float3 iblCol = 0;
    if(_EnvMapOn)
        iblCol = CalcIbl(_EnvMap,a,input.reflectDir) * _EnvMapIntensity * iblMask;
    // return matCap;
    // sample the texture
    half4 col = tex2D(_MainTex, input.uv) * _Color;

    col.xyz = (col.xyz + (matCap.xyz * matCapMask) + iblCol) * wnl;
    return col;
}

#endif //POWER_MATCAP_FORWARD_PASS_HLSL