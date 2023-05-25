#if !defined(POWER_MATCAP_FORWARD_PASS_HLSL)
#define POWER_MATCAP_FORWARD_PASS_HLSL
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/Lib/BSDF.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../PowerShaderLib/URPLib/URP_GI.hlsl"
#include "../../PowerShaderLib/URPLib/Lighting.hlsl"
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
    float3 viewDirTS:TEXCOORD6;
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
    o.viewDirTS = WorldToTangent(viewDir,o.tSpace0,o.tSpace1,o.tSpace2);
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
        normal = (TangentToWorld(tn,input.tSpace0,input.tSpace1,input.tSpace2));
    }
    
    float nl = saturate(dot(_MainLightPosition.xyz,normal));// * 0.5+0.5;;
    float4 matCap = CalcMatCap(normal) * _MatCapScale;

    // mask
    float4 maskTex = SAMPLE_TEXTURE2D(_EnvMask,sampler_EnvMask,input.uv);
    float matCapMask = maskTex.x;
    float iblMask = maskTex.y;

    float4 pbrMask = SAMPLE_TEXTURE2D(_PbrMask,sampler_PbrMask,input.uv);
    float metallic,smoothness,occlusion;
    SplitPbrMaskTexture(metallic/**/,smoothness/**/,occlusion/**/,pbrMask,int3(0,1,2),float3(_Metallic,_Smoothness,_Occlusion),_IsSmoothnessReversed);

    float rough,a,a2;
    CalcRoughness(rough/**/,a/**/,a2/**/,smoothness);

    float3 lightDir = _MainLightPosition.xyz;
    float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);

    float3 h = normalize(lightDir + viewDir);
    float nv = saturate(dot(normal,viewDir));
    float nh = saturate(dot(normal,h));
    float lh = saturate(dot(lightDir,h));

    // sample the texture
    half4 mainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,input.uv);
    half3 albedo = 0;
    half alpha = 0;
    CalcSurfaceColor(albedo/**/,alpha/**/,mainTex,_Color,_Cutoff,metallic,_AlphaPremultiply,_AlphaChannel);

    half3 diffColor = albedo * (1-metallic);
    half3 specColor = lerp(0.04,albedo,metallic);

    // gi diff
    half3 giDiff = 0;
    branch_if(_CustomGIDiff){
        giDiff = diffColor* _GIDiffColor;
    }else{
        giDiff = CalcGIDiff(normal,diffColor);
    }

    // float3 reflectDir =(CalcInteriorMapReflectDir(normalize(input.viewDirTS),input.uv));
    // // return reflectDir.xyzx;
    // float3 iblCol= CalcIBL(reflectDir,_EnvMap,sampler_EnvMap,rough,_EnvMap_HDR);
    // return float4(iblCol,1);

    half3 giSpec = CalcGISpec(_EnvMap,sampler_EnvMap,_EnvMap_HDR,specColor,worldPos,normal,viewDir,_EnvMapOffset,_EnvMapIntensity,nv,rough,a2,smoothness,metallic,_FresnelWidth,_FresnelColor);

    // direct lighting
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    half shadowAtten = CalcShadow(shadowCoord,worldPos,0.1);

    // return shadowAtten;
    half3 radiance = nl * _MainLightColor.xyz * shadowAtten;
    half3 specTerm = MinimalistCookTorrance(nh,lh,a,a2);

    specTerm += matCap.xyz;

    half4 col = 0;
    // main light
    col.xyz = (giDiff + giSpec) * occlusion;
    col.xyz += (diffColor + specColor * specTerm) * radiance;

    // additional lights
    #if defined(_ADDITIONAL_LIGHTS_ON)
        float4 shadowMask = 1;
        col.xyz += CalcAdditionalLights(worldPos,diffColor,specColor,normal,viewDir,a,a2,shadowMask);
    #endif
    col.w = alpha;
    return col;
}

#endif //POWER_MATCAP_FORWARD_PASS_HLSL