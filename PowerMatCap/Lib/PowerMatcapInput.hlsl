#if !defined(POWER_MATCAP_INPUT_HLSL)
#define POWER_MATCAP_INPUT_HLSL

TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);
TEXTURE2D(_NormalMap);SAMPLER(sampler_NormalMap);
TEXTURE2D(_DetailNormalMap);SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_MatCap);SAMPLER(sampler_MatCap);
TEXTURE2D(_EnvMask);SAMPLER(sampler_EnvMask);
TEXTURECUBE(_EnvMap);SAMPLER(sampler_EnvMap);
TEXTURE2D(_PbrMask);SAMPLER(sampler_PbrMask);

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
float4 _Color;

float _NormalMapOn;
float _NormalScale;
float4 _NormalMap_ST;

float _DetailNormalScale;
float4 _DetailNormalMap_ST;

float _MatCapScale;
float4 _MatCap_ST;

float _EnvMapIntensity;
float3 _EnvMapOffset;
float4 _EnvMap_HDR;
half4 _FresnelColor;
float2 _FresnelWidth;

half _Smoothness;
half _Metallic;
half _Occlusion;
half _IsSmoothnessReversed;

half _AlphaPremultiply;
half _Cutoff;

half _CustomShadowNormalBias;
half _CustomShadowDepthBias;
CBUFFER_END

#endif //POWER_MATCAP_INPUT_HLSL