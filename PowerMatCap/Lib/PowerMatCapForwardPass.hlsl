#if !defined(POWER_MATCAP_FORWARD_PASS_HLSL)
#define POWER_MATCAP_FORWARD_PASS_HLSL
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/URPLib/URP_GI.hlsl"
#include "Lib/PowerMatCapInput.hlsl"

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

    float3 viewDir = normalize(GetWorldSpaceViewDir(p));
    float3 reflectDir = reflect(-viewDir,n);
    o.reflectDir = (reflectDir+_EnvMapOffset);
    return o;
}

float4 CalcMatCap(float3 normal){
    float3 normalView = mul(UNITY_MATRIX_V,float4(normal,0)).xyz;
    normalView = normalView*0.5+0.5;

    float2 matUV = (normalView.xy) * _MatCap_ST.xy + _MatCap_ST.zw;
    float4 matCap = SAMPLE_TEXTURE2D(_MatCap,sampler_MatCap,matUV);
    return matCap;
}

float3 BlendNormal(float3 a,float3 b){
    return normalize(float3(a.xy*b.z+b.xy*a.z,a.z*b.z));
}

float3 CalcIbl(TEXTURECUBE_PARAM(cubemap,sampler_cubemap),half4 cubemapHDR,float rough,float3 reflectDir){
    float mip = (1.7-0.7*rough) * rough * 6; 
    float4 cubeCol = SAMPLE_TEXTURECUBE_LOD(cubemap,sampler_cubemap,reflectDir,mip);
    return DecodeHDREnvironment(cubeCol,cubemapHDR);
}

half4 frag (v2f input) : SV_Target
{
    TANGENT_SPACE_SPLIT(input);
    
    branch_if(_NormalMapOn)
    {
        float2 normalUV = input.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
        float2 detailUV = input.uv *  _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;

        float3 tn = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,normalUV),_NormalScale);
        float3 detailTN = UnpackNormalScale(SAMPLE_TEXTURE2D(_DetailNormalMap,sampler_DetailNormalMap,detailUV),_DetailNormalScale);
        tn = BlendNormal(tn,detailTN);
        normal = TangentToWorld(tn,input.tSpace0,input.tSpace1,input.tSpace2);
    }
    
    float wnl = dot(_MainLightPosition.xyz,normal);// * 0.5+0.5;;
    float4 matCap = CalcMatCap(normal) * _MatCapScale;

    // mask
    float4 maskTex = SAMPLE_TEXTURE2D(_EnvMask,sampler_EnvMask,input.uv);
    float matCapMask = maskTex.x;
    float iblMask = maskTex.y;

    float4 pbrMask = SAMPLE_TEXTURE2D(_PbrMask,sampler_PbrMask,input.uv);

    float metallic = _Metallic * pbrMask[0];
    float smoothness = _Smoothness * pbrMask[1];
    float rough = 1- smoothness;
    float a = max(rough * rough,HALF_MIN_SQRT);
    float a2 = max(a*a,HALF_MIN);
    float occlusion = lerp(1,pbrMask[2],_Occlusion);

    float3 lightDir = _MainLightPosition.xyz;
    float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);

    float3 h = normalize(lightDir + viewDir);
    float nv = saturate(dot(normal,viewDir));
    float nh = saturate(dot(normal,h));
    float lh = saturate(dot(lightDir,h));

    // sample the texture
    half4 mainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,input.uv) * _Color;
    half3 albedo = mainTex.xyz;
    half alpha = mainTex.w;

    #if defined(ALPHA_TEST)
        clip(alpha - _Cutoff);
    #endif

    branch_if(_AlphaPremultiply)
    {
        albedo *= alpha;
        alpha = lerp(alpha+0.04,1,metallic);
    }

    half3 diffColor = albedo * (1-metallic);
    half3 specColor = lerp(0.04,albedo,metallic);

    // gi spec
    half surfaceReduction = 1/(a2+1);
    half fresnelTerm = pow(1-nv,4);
    fresnelTerm = smoothstep(_FresnelWidth.x,_FresnelWidth.y,fresnelTerm);

    half3 grazingTerm = saturate(smoothness + metallic);
    grazingTerm *= _FresnelColor;

    half3 iblCol = CalcIbl(_EnvMap,sampler_EnvMap,_EnvMap_HDR,rough,normalize(input.reflectDir)) * _EnvMapIntensity;
    half3 giSpec = iblCol * lerp(specColor,grazingTerm,fresnelTerm) * surfaceReduction;

    // gi diff
    half3 sh = SampleSH(normal);
    half3 giDiff = sh * diffColor;

    // direct lighting
    half radiance = wnl;

    half d = nh*nh *(a2-1)+1;
    half3 specTerm = a2/(d*d * max(0.0001,lh*lh) * (4*a+2));
    specTerm += matCap.xyz;

    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
        specTerm = clamp(specTerm,0,100);
    #endif

    half4 col = 0;
    col.xyz = (diffColor + specColor * specTerm) * radiance  * _MainLightColor.xyz;
    col.xyz += (giDiff + giSpec) * occlusion;
    col.w = alpha;
    return col;
}

#endif //POWER_MATCAP_FORWARD_PASS_HLSL