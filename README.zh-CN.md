# PowerMatCap

[English](README.md) | [简体中文](README.zh-CN.md)

## 简介

PowerMatCap 是一个面向移动设备的 MatCap 着色器，支持 MatCap 光照、IBL（基于图像的光照）、PBR 表面选项以及顶点 GPU 蒙皮（GPU skinning）。它基于 PowerUtilities 等公共库构建，适合在移动端实现高性能的 MatCap 风格角色渲染。

文档: 参见下方「参考仓库 / 依赖（Reference Gits）」章节，即 https://github.com/redcool/PowerUtilities.git 仓库。

## 功能特性（Features）

着色器（`PowerMatCap/PowerMatCap.shader`，头部版本号 `v0.0.4`）— `Shader "Character/PowerMatcap"`、`#pragma target 3.0`，面向移动端：

- **MatCap 光照**：`_MatCap` 贴图由世界法线经 `MatCapLib`（`SampleMatCap`、`MATCAP_UV_ROTATE` + `_MatCapAngle`）采样，另有 `_MatCapScale`、`_MatCapWidth`（最小/最大重映射）、`_EnvMask`（R：MatcapMask，G：IBLMask）
- **主通道输出 MRT（多渲染目标）**：`SV_TARGET1` 世界法线（+ 光滑度 * `_MRTSmoothness`，供 SSR 屏幕空间反射使用）、`SV_TARGET2` 运动矢量（URP_MotionVectors）— 参见 `Lib/PowerMatCapForwardPass.hlsl`
- **主光源**（`GetMainLight` + shadowMask/光照贴图）+ 启用 `_PBROn`（`_PBR_ON`）时的 `MinimalistCookTorrance` 高光；`_SMOOTH_FRESNEL` 菲涅尔项
- **PBR 表面选项**：`_PbrMask`（R：金属度 Metallic，G：光滑度 Smoothness，B：环境光遮蔽 Occlusion）配合 `_Metallic/_Smoothness/_Occlusion`、`_IsSmoothnessReversed`（经 `SplitPbrMaskTexture`/`CalcRoughness` 实现）
- **IBL**：`_EnvMap`（立方体贴图）配合 `_EnvMapIntensity`、`_EnvMapOffset`、`_FresnelWidth/_FresnelColor`（`CalcGISpec`）
- **溶解效果（Dissolve）**：`_DissolveOn`（`_DISSOLVE_ON`）、`_DissolveNoiseTex`、基于本地坐标的溶解 `_MinLocalPos/_MaxLocalPos/_DissolveRange/_DissolveValue`，带边缘噪点（`CalcPosDissolve`，裁剪 `alphaRate.y`）
- **法线**：`_NormalMap`（`_NORMAL`）+ `_DetailNormalMap`、`_NormalScale`、`_DetailNormalScale`，经 `BlendNormal` 混合
- **自发光（Emission）**：`_EmissionOn`（`_EMISSION`）、`_EmissionMap`（rgb 颜色，同时作为遮罩）、`_EmissionColor`（w：遮罩）
- **雾效（天气）**：`_FogOn/_FogNoiseOn/_DepthFogOn/_HeightFogOn`，经 `BlendFogSphereKeyword` 实现
- **附加光源**：`_ADDITIONAL_LIGHTS_ON`（`CalcAdditionalLights`）+ `_ADDITIONAL_LIGHT_SHADOWS`
- **GI**：`_CustomGIDiff/_GIDiffColor` 自定义漫反射 GI 或 `CalcGIDiff`
- **GPU 顶点蒙皮 / AnimTex**：`_GpuSkinnedOn`（`None/_ANIM_TEX_ON/_GPU_SKINNED_ON`）— 从 `AnimTextureLib.hlsl` 调用 `CalcBlendAnimPos`/`CalcSkinnedPos`，支持动画范围/`_PlayTime`/`_CrossLerp` 下一段动画交叉淡化（crossfade）
- **Alpha**：`_PresetBlendMode`、`_AlphaPremultiply`、`_AlphaTestOn`（`ALPHA_TEST`）+ `_Cutoff`、`_AlphaChannel`（r/g/b/a）
- **阴影（Shadow）**：`_ReceiveShadowOff`（`_RECEIVE_SHADOWS_OFF`）、`_MainLightShadowSoftScale`、自定义 `_CustomShadowNormalBias/_CustomShadowDepthBias`
- **设置（Settings）**：Cull/ZWrite/ZTest + Stencil（模板）块
- 通道（Passes）：`PowerMatCap`（UniversalForward）、`DepthOnly`、`ShadowCaster`（自定义偏置，`_CASTING_PUNCTUAL_LIGHT_SHADOW`）

Lib 库：

- `Lib/PowerMatCapForwardPass.hlsl` — 前向渲染片元着色器：法线混合、溶解、matcap 采样 + 遮罩、PBR 拆分、主光源 + Cook-Torrance、IBL 菲涅尔、雾效、自发光、灰度模式（`_GrayOn`）、MRT 法线/运动矢量输出
- `Lib/PowerMatcapInput.hlsl` — 贴图/采样器声明 + `UnityPerMaterial` CBUFFER

材质：

- `Unlit_PowerMatCap.mat` — MatCap = `Tex/IceCap.psd`，另有 `_EnvMap` 立方体贴图、`_NormalMap` + `_DetailNormalMap`、自发光、附加光源（`_ADDITIONAL_LIGHTS_ON`）
- `Assets/Unlit_Matcap.mat` — MatCap = `Tex/2.bmp`，另有 `_EnvMap` 立方体贴图与 `_EnvMask`

演示资源：

- `Assets/` — `Box.FBX` 礼品盒网格、`t_gift_box_dif(.mask).tga` / `t_gift_box_nom.tga` 贴图、`pbr.mat`（URP Lit 参考材质）
- `Tex/` — matcap 贴图 `1-9`（bmp/jpg）、`IceCap.psd`、`pointLights.png`
- `Scenes/TestMatcap.unity` — 演示场景：matcapSphere（使用 `Assets/Unlit_Matcap.mat` 渲染）+ 方向光（Directional Light）

## 目录结构（Folder structure）

```
PowerMatCap/
└── PowerMatCap/
    ├── PowerMatCap.asmdef          # 引用 PowerUtilities、PowerCoreUtilities、PowerEditorUtilities
    ├── PowerMatCap.shader          # Character/PowerMatcap
    ├── Lib/
    │   ├── PowerMatCapForwardPass.hlsl
    │   └── PowerMatcapInput.hlsl
    ├── Assets/                     # Box.FBX 礼品盒 + t_gift_box_* 贴图 + Unlit_Matcap.mat + pbr.mat
    ├── Tex/                        # matcap 贴图 1-9、IceCap.psd、pointLights.png
    ├── Scenes/TestMatcap.unity     # 演示场景
    └── Unlit_PowerMatCap.mat       # 示例材质
```

## 使用说明（Usage）

1. 使用 `Character/PowerMatcap` 创建一个材质
2. 为 `_MatCap` 指定一张 matcap 贴图（例如 `Tex/` 目录中的一张），并按需指定 `_EnvMask` 以及用于 IBL 的 `_EnvMap` 立方体贴图
3. 设置 `_MatCapScale`、`_MatCapWidth`、`_MatCapAngle` 以调节 matcap 效果；按需启用开关（`_PBROn`、`_NormalMapOn`、`_DissolveOn`、`_EmissionOn`、雾效，使用 AnimTex/GPU 蒙皮时启用 `_GpuSkinnedOn`）
4. 打开 `Scenes/TestMatcap.unity` 即可查看现成的 matcap 演示

## 参考仓库 / 依赖（Reference Gits）

https://github.com/redcool/PowerUtilities.git

本项目依赖上述仓库，请将其放在与项目相同的目录下。

## 备注 / 更新记录（Notes / Changelog）

- v0.0.4：着色器属性头部版本号（位于 PowerMatCap.shader 中）
- 面向移动端的 matcap 着色器；需要 PowerUtilities（+ PowerCoreUtilities / PowerEditorUtilities）
