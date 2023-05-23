Shader "Character/PowerMatcap"
{
    Properties
    {
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
        [GroupToggle(Env Light)]_EnvMapOn("_EnvMapOn",float) = 0
        [GroupItem(Env Light)][NoScaleOffset]_EnvMap("_EnvMap",cube) = ""{}
        [GroupItem(Env Light)]_EnvMapIntensity("_EnvMapIntensity",range(0,1)) = 0.5
        [GroupItem(Env Light)]_EnvMapOffset("_EnvMapOffset",vector) = (0,0,0,0)
        // [GroupItem(Env Light)]_EnvMapTiling("_EnvMapTiling",range(0,5)) = 1

        [GroupHeader(Env Light,Fresnel)]
        [GroupVectorSlider(Env Light,FresnelWidthMin FresnelWidthMax,0_1 0_1)]_FresnelWidth("_FresnelWidth",vector) = (0,1,0,0)
        [GroupItem(Env Light)][hdr]_FresnelColor("_FresnelColor",color)  =(1,1,1,1)

        [Group(Settings)]
        [GroupHeader(Settings,BlendMode)]
        [GroupEnum(Settings,UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [GroupEnum(Settings,UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0

        [GroupHeader(Settings,Alpha)]
        [GroupToggle(Settings)]_AlphaPremultiply("_AlphaPremultiply",int) = 0
    }
    SubShader
    {
        Tags { "LightMode"="UniversalForward" }
        LOD 100

        Pass
        {
            Blend [_SrcMode][_DstMode]
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #include "Lib/PowerMatCapForwardPass.hlsl"

            ENDHLSL
        }
    }
}

