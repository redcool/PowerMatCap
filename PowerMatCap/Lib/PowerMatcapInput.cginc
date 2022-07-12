#if !defined(POWER_MATCAP_INPUT_CGINC)
#define POWER_MATCAP_INPUT_CGINC

sampler2D _MainTex;
sampler2D _NormalMap;
sampler2D _DetailNormalMap;
sampler2D _MatCap;
sampler2D _EnvMask;
samplerCUBE _EnvMap;

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
float4 _Color;

float _NormalMapOn;
float _NormalScale;
float4 _NormalMap_ST;

float _DetailNormalScale;
float4 _DetailNormalMap_ST;

float _MatCapScale;

float _EnvMapOn;
float _EnvMapIntensity;
float3 _EnvMapOffset;
float _Smoothness;
float _Metallic;
CBUFFER_END

#endif //POWER_MATCAP_INPUT_CGINC