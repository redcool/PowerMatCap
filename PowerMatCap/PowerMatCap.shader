﻿Shader "Character/PowerMatcap"
{
    Properties
    {
        [GroupHeader(v0.0.3)]
        [Group(Main)]
        [GroupHeader(Main,Main)]
        [GroupItem(Main)]_MainTex ("_MainTex", 2D) = "white" {}
        [GroupItem(Main)][hdr]_Color("_Color",color)=(1,1,1,1)

        [GroupHeader(Main,Normal)]
        [GroupToggle(Main)]_NormalMapOn("_NormalMapOn",float) = 0
        [GroupItem(Main)]_NormalMap("_NormalMap",2d)= ""{}
        [GroupItem(Main)]_NormalScale("_NormalScale",range(0,10)) = 1

        [GroupItem(Main)]_DetailNormalMap("_DetailNormalMap",2d)=""{}
        [GroupItem(Main)]_DetailNormalScale("_DetailNormalScale",range(0,10)) = 1

        [Group(Surface)]
        [GroupItem(Surface)]_PbrMask("_PbrMask(R:Metallic,G:Smoothness,B:Occlusion)",2d)="white"{}
        [GroupItem(Surface)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(Surface)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(Surface)]_Occlusion("_Occlusion",range(0,1)) = 0
        
        [Group(Env Light)]
        [GroupItem(Env Light)][NoScaleOffset]_EnvMask("_EnvMask(R:MatcapMask,G:IBLMask)",2d) = "white"{}

        [GroupHeader(Env Light,Matcap)]
        [GroupItem(Env Light)]_MatCap("_MatCap",2d)=""{}
        [GroupItem(Env Light)]_MatCapScale("_MatCapScale",range(0,10)) = 1

        [GroupHeader(Env Light,IBL)]
        [GroupItem(Env Light)][NoScaleOffset]_EnvMap("_EnvMap",cube) = ""{}
        [GroupItem(Env Light)]_EnvMapIntensity("_EnvMapIntensity",range(0,1)) = 0.5
        [GroupItem(Env Light)]_EnvMapOffset("_EnvMapOffset",vector) = (0,0,0,0)

        [GroupHeader(Env Light,Fresnel)]
        [GroupVectorSlider(Env Light,FresnelWidthMin FresnelWidthMax,0_1 0_1)]_FresnelWidth("_FresnelWidth",vector) = (0,1,0,0)
        [GroupItem(Env Light)][hdr]_FresnelColor("_FresnelColor",color)  =(1,1,1,1)

        [Group(Alpha)]
        [GroupHeader(Alpha,BlendMode)]
        [GroupPresetBlendMode(Alpha,,_SrcMode,_DstMode)]_PresetBlendMode("_PresetBlendMode",int)=0
        // [GroupEnum(Alpha,UnityEngine.Rendering.BlendMode)]
        [HideInInspector]_SrcMode("_SrcMode",int) = 1
        [HideInInspector]_DstMode("_DstMode",int) = 0

        [GroupHeader(Alpha,Premultiply)]
        [GroupToggle(Alpha)]_AlphaPremultiply("_AlphaPremultiply",int) = 0

        [GroupHeader(Alpha,AlphaTest)]
        [GroupToggle(Alpha,ALPHA_TEST)]_AlphaTestOn("_AlphaTestOn",int) = 0
        [GroupSlider(Alpha)]_Cutoff("_Cutoff",range(0,1)) = 0.5
    }
    SubShader
    {
        LOD 100

        Pass
        {
            Tags { "LightMode"="UniversalForward" }
            Blend [_SrcMode][_DstMode]
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ ALPHA_TEST

            #include "Lib/PowerMatCapForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Tags { "LightMode"="DepthOnly" }
            
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment  ALPHA_TEST

            #include "../../PowerShaderLib/Lib/UnityLib.hlsl"
            #include "Lib/PowerMatCapInput.hlsl"
            #define _MainTexChannel 2
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Tags { "LightMode"="ShadowCaster" }
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment ALPHA_TEST

            #include "../../PowerShaderLib/Lib/UnityLib.hlsl"
            #include "Lib/PowerMatCapInput.hlsl"
            #define SHADOW_PASS
            #define _MainTexChannel 3
            
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }        
    }
}

