#if !defined(POWER_MATCAP_FORWARD_PASS_HLSL)
#define POWER_MATCAP_FORWARD_PASS_HLSL
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/Lib/BSDF.hlsl"
#include "../../PowerShaderLib/Lib/MaterialLib.hlsl"
#include "../../PowerShaderLib/URPLib/URP_GI.hlsl"
#include "../../PowerShaderLib/URPLib/Lighting.hlsl"
#include "../../PowerShaderLib/Lib/MatCapLib.hlsl"
#include "../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../PowerShaderLib/Lib/MathLib.hlsl"
#include "../../PowerShaderLib/URPLib/URP_MotionVectors.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    DECLARE_MOTION_VS_INPUT(prevPos);
};

struct v2f
{
    float4 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;

    float4 fogCoord:TEXCOORD1;//fogCoord{x,y}, z:heightColorAtten    
    TANGENT_SPACE_DECLARE(2,3,4);
    float3 reflectDir:TEXCOORD5;
    // motion vectors    
    DECLARE_MOTION_VS_OUTPUT(6,7);
};

v2f vert (appdata v)
{
    v2f o = (v2f)0;
    o.vertex = TransformObjectToHClip(v.vertex.xyz);
    o.uv = float4(v.uv,TRANSFORM_TEX(v.uv, _MainTex));
    TANGENT_SPACE_COMBINE(v.vertex,v.normal,v.tangent,o/**/);
    o.fogCoord.xy = CalcFogFactor(p.xyz,o.vertex.z,_HeightFogOn,_DepthFogOn);

    float3 viewDir = normalize(GetWorldSpaceViewDir(p));
    float3 reflectDir = reflect(-viewDir,n);
    o.reflectDir = (reflectDir+_EnvMapOffset);

    CALC_MOTION_POSITIONS(v.prevPos,v.vertex,o,o.vertex);

    return o;
}

float3 BlendNormal(float3 a,float3 b){
    return normalize(float3(a.xy*b.z+b.xy*a.z,a.z*b.z));
}

half4 frag (v2f input,
    out float4 outputNormal:SV_TARGET1,
    out float4 outputMotionVectors:SV_TARGET2
) : SV_Target
{
    TANGENT_SPACE_SPLIT(input);

    #if defined(_NORMAL)
    // branch_if(_NormalMapOn)
    {
        float2 normalUV = input.uv * _NormalMap_ST.xy + _NormalMap_ST.zw;
        float2 detailUV = input.uv *  _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;

        float3 tn = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,normalUV),_NormalScale);
        float3 detailTN = UnpackNormalScale(SAMPLE_TEXTURE2D(_DetailNormalMap,sampler_DetailNormalMap,detailUV),_DetailNormalScale);
        tn = BlendNormal(tn,detailTN);
        normal = (TangentToWorld(tn,input.tSpace0,input.tSpace1,input.tSpace2));
    }
    #endif

    // mask
    float4 maskTex = SAMPLE_TEXTURE2D(_EnvMask,sampler_EnvMask,input.uv);
    float matCapMask = maskTex.x;
    float iblMask = maskTex.y;
    
    float nl = saturate(dot(_MainLightPosition.xyz,normal));// * 0.5+0.5;;
    float4 matCap = SampleMatCap(_MatCap,sampler_MatCap,normal,_MatCap_ST,_MatCapAngle);
    // matCap.xyz = pow(matCap.xyz,_MatCapWidth.z);
    matCap.xyz += smoothstep(_MatCapWidth.x,_MatCapWidth.y,matCap.xyz);
    matCap.xyz *= _MatCapScale * matCapMask;

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

    //-------- output mrt
    // output world normal
    outputNormal = half4(normal.xyz,smoothness * _MRTSmoothness);
    // output motion
    outputMotionVectors = CALC_MOTION_VECTORS(input);

    // sample the texture
    half4 mainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,input.uv.zw);
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
    
    half3 giSpec = CalcGISpec(_EnvMap,sampler_EnvMap,_EnvMap_HDR,specColor,worldPos,normal,viewDir,_EnvMapOffset,_EnvMapIntensity * iblMask,nv,rough,a2,smoothness,metallic,_FresnelWidth,_FresnelColor);

    // direct lighting
    float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
    half shadowAtten = CalcShadow(shadowCoord,worldPos,0.1);

    // return shadowAtten;
    half3 radiance = nl * _MainLightColor.xyz * shadowAtten;

    half3 specTerm = matCap.xyz;
    #if defined(_PBR_ON)
        specTerm += MinimalistCookTorrance(nh,lh,a,a2);
    #endif

    half4 col = 0;
    // main light
    col.xyz = (giDiff + giSpec) * occlusion;
    col.xyz += (diffColor + specColor * specTerm) * radiance;

    // additional lights
    #if defined(_ADDITIONAL_LIGHTS_ON)
        float4 shadowMask = 1;
        col.xyz += CalcAdditionalLights(worldPos,diffColor,specColor,normal,viewDir,a,a2,shadowMask);
    #endif

//------ emission
    half3 emissionColor = 0;
    #if defined(_EMISSION)
        emissionColor += CalcEmission(SAMPLE_TEXTURE2D(_EmissionMap,sampler_EmissionMap,input.uv),_EmissionColor.xyz,_EmissionColor.w);
    #endif
    col.xyz += emissionColor;
//------ fog
    // col.rgb = MixFog(col.xyz,i.fogFactor.x);
    BlendFogSphereKeyword(col.rgb/**/,worldPos,input.fogCoord.xy,_HeightFogOn,_FogNoiseOn,_DepthFogOn); // 2fps

    col.w = alpha;
    return col;
}

#endif //POWER_MATCAP_FORWARD_PASS_HLSL