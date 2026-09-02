# PowerMatCap

[English](README.md) | [简体中文](README.zh-CN.md)

A matcap shader for mobile devices, with matcap lighting, IBL, PBR surface options and vertex GPU skinning

Docs: see Reference Git below

## Features (from code)

Shader (`PowerMatCap/PowerMatCap.shader`, header `v0.0.4`) — `Shader "Character/PowerMatcap"`, `#pragma target 3.0` mobile-oriented:

- **Matcap lighting**: `_MatCap` texture sampled by world normal via `MatCapLib` (`SampleMatCap`, `MATCAP_UV_ROTATE` + `_MatCapAngle`), with `_MatCapScale`, `_MatCapWidth` (min/max remap), `_EnvMask` (R: MatcapMask, G: IBLMask)
- **Main pass outputs MRTs**: `SV_TARGET1` world normal (+ smoothness * `_MRTSmoothness` for SSR), `SV_TARGET2` motion vectors (URP_MotionVectors) — see `Lib/PowerMatCapForwardPass.hlsl`
- **Main light** (`GetMainLight` + shadowMask/lightmap) + `MinimalistCookTorrance` specular when `_PBROn` (`_PBR_ON`); `_SMOOTH_FRESNEL` fresnel term
- **PBR surface options**: `_PbrMask` (R: Metallic, G: Smoothness, B: Occlusion) with `_Metallic/_Smoothness/_Occlusion`, `_IsSmoothnessReversed` (via `SplitPbrMaskTexture`/`CalcRoughness`)
- **IBL**: `_EnvMap` (cubemap) with `_EnvMapIntensity`, `_EnvMapOffset`, `_FresnelWidth/_FresnelColor` (`CalcGISpec`)
- **Dissolve effect**: `_DissolveOn` (`_DISSOLVE_ON`), `_DissolveNoiseTex`, local-position dissolve `_MinLocalPos/_MaxLocalPos/_DissolveRange/_DissolveValue` with edge noise (`CalcPosDissolve`, clip `alphaRate.y`)
- **Normals**: `_NormalMap` (`_NORMAL`) + `_DetailNormalMap`, `_NormalScale`, `_DetailNormalScale`, blended via `BlendNormal`
- **Emission**: `_EmissionOn` (`_EMISSION`), `_EmissionMap` (rgb color, a mask), `_EmissionColor` (w: mask)
- **Fog (weather)**: `_FogOn/_FogNoiseOn/_DepthFogOn/_HeightFogOn` via `BlendFogSphereKeyword`
- **Additional lights**: `_ADDITIONAL_LIGHTS_ON` (`CalcAdditionalLights`) + `_ADDITIONAL_LIGHT_SHADOWS`
- **GI**: `_CustomGIDiff/_GIDiffColor` custom diffuse GI or `CalcGIDiff`
- **GPU vertex skinning / AnimTex**: `_GpuSkinnedOn` (`None/_ANIM_TEX_ON/_GPU_SKINNED_ON`) — `CalcBlendAnimPos`/`CalcSkinnedPos` from `AnimTextureLib.hlsl`, anim range/`_PlayTime`/`_CrossLerp` next-anim crossfade
- **Alpha**: `_PresetBlendMode`, `_AlphaPremultiply`, `_AlphaTestOn` (`ALPHA_TEST`) + `_Cutoff`, `_AlphaChannel` (r/g/b/a)
- **Shadow**: `_ReceiveShadowOff` (`_RECEIVE_SHADOWS_OFF`), `_MainLightShadowSoftScale`, custom `_CustomShadowNormalBias/_CustomShadowDepthBias`
- **Settings**: Cull/ZWrite/ZTest + Stencil block
- Passes: `PowerMatCap` (UniversalForward), `DepthOnly`, `ShadowCaster` (custom bias, `_CASTING_PUNCTUAL_LIGHT_SHADOW`)

Lib:

- `Lib/PowerMatCapForwardPass.hlsl` — forward fragment shader: normal blend, dissolve, matcap sampling + mask, PBR split, main light + Cook-Torrance, IBL fresnel, fog, emission, gray mode (`_GrayOn`), MRT normal/motion outputs
- `Lib/PowerMatcapInput.hlsl` — texture/sampler declarations + `UnityPerMaterial` CBUFFER

Materials:

- `Unlit_PowerMatCap.mat` — MatCap = `Tex/IceCap.psd`, plus `_EnvMap` cubemap, `_NormalMap` + `_DetailNormalMap`, emission, additional lights (`_ADDITIONAL_LIGHTS_ON`)
- `Assets/Unlit_Matcap.mat` — MatCap = `Tex/2.bmp`, plus `_EnvMap` cubemap and `_EnvMask`

Demo assets:

- `Assets/` — `Box.FBX` gift-box mesh, `t_gift_box_dif(.mask).tga` / `t_gift_box_nom.tga` textures, `pbr.mat` (URP Lit reference)
- `Tex/` — matcap textures `1-9` (bmp/jpg), `IceCap.psd`, `pointLights.png`
- `Scenes/TestMatcap.unity` — demo scene: matcapSphere (rendered with `Assets/Unlit_Matcap.mat`) + Directional Light

## Folder structure

```
PowerMatCap/
└── PowerMatCap/
    ├── PowerMatCap.asmdef          # references PowerUtilities, PowerCoreUtilities, PowerEditorUtilities
    ├── PowerMatCap.shader          # Character/PowerMatcap
    ├── Lib/
    │   ├── PowerMatCapForwardPass.hlsl
    │   └── PowerMatcapInput.hlsl
    ├── Assets/                     # Box.FBX gift box + t_gift_box_* textures + Unlit_Matcap.mat + pbr.mat
    ├── Tex/                        # matcap textures 1-9, IceCap.psd, pointLights.png
    ├── Scenes/TestMatcap.unity     # demo scene
    └── Unlit_PowerMatCap.mat       # example material
```

## Setup / Usage

1. Create a material with `Character/PowerMatcap`
2. Assign a matcap texture to `_MatCap` (e.g. one from `Tex/`) and optionally an `_EnvMask` and an `_EnvMap` cubemap for IBL
3. Set `_MatCapScale`, `_MatCapWidth`, `_MatCapAngle` to tune the matcap look; enable toggles as needed (`_PBROn`, `_NormalMapOn`, `_DissolveOn`, `_EmissionOn`, fog, `_GpuSkinnedOn` for AnimTex/GPU skinning)
4. Open `Scenes/TestMatcap.unity` for a ready-made matcap demo

## Reference Git

https://github.com/redcool/PowerUtilities.git

## Changelog / Notes

- v0.0.4: shader property header version (in PowerMatCap.shader)
- Mobile-oriented matcap shader; requires PowerUtilities (+ PowerCoreUtilities / PowerEditorUtilities)