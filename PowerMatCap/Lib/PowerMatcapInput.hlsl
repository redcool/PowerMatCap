#if !defined(POWER_MATCAP_INPUT_HLSL)
#define POWER_MATCAP_INPUT_HLSL
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"

TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);
TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
TEXTURE2D(_DetailNormalMap);SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_MatCap);SAMPLER(sampler_MatCap);
TEXTURE2D(_EnvMask);SAMPLER(sampler_EnvMask);
TEXTURECUBE(_EnvMap);SAMPLER(sampler_EnvMap);
TEXTURE2D(_PbrMask);SAMPLER(sampler_PbrMask);
TEXTURE2D(_EmissionMap);SAMPLER(sampler_EmissionMap);

CBUFFER_START(UnityPerMaterial)
half4 _MainTex_ST;
half4 _Color;
half _AlphaChannel;

// half _NormalMapOn;
half _NormalScale;
half4 _NormalMap_ST;

half _DetailNormalScale;
half4 _DetailNormalMap_ST;

half _MatCapScale;
half4 _MatCap_ST;
half3 _MatCapWidth;
half _MatCapAngle;

half _EnvMapIntensity;
half3 _EnvMapOffset;
half4 _EnvMap_HDR;
half4 _FresnelColor;
half2 _FresnelWidth;

half _Smoothness;
half _Metallic;
half _Occlusion;
half _IsSmoothnessReversed;

half _CustomGIDiff;
half4 _GIDiffColor;

half _AlphaPremultiply;
half _Cutoff;

half _CustomShadowNormalBias;
half _CustomShadowDepthBias;
//----------------------------------------
half4 _EmissionColor;
//----------------------------------------
half _FogOn;
half _FogNoiseOn;
half _DepthFogOn;
half _HeightFogOn;

CBUFFER_END

#endif //POWER_MATCAP_INPUT_HLSL