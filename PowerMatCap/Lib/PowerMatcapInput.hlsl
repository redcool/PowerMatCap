#if !defined(POWER_MATCAP_INPUT_HLSL)
#define POWER_MATCAP_INPUT_HLSL

sampler2D _MainTex;
sampler2D _NormalMap;
sampler2D _DetailNormalMap;
sampler2D _MatCap;
sampler2D _EnvMask;
samplerCUBE _EnvMap;
sampler2D _PbrMask;

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

float _Smoothness;
float _Metallic;
float _Occlusion;

half _AlphaPremultiply;
CBUFFER_END

#endif //POWER_MATCAP_INPUT_HLSL