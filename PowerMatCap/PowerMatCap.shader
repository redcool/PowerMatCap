Shader "PowerXXX/PowerMatcap"
{
    Properties
    {
        [Group(Main)]
        [GroupHeader(Main,Main)]
        [GroupItem(Main)]_MainTex ("_MainTex", 2D) = "white" {}
        [GroupItem(Main)]_Color("_Color",color)=(1,1,1,1)

        [GroupHeader(Main,Normal)]
        [GroupToggle(Main)]_NormalMapOn("_NormalMapOn",float) = 0
        [GroupItem(Main)]_NormalMap("_NormalMap",2d)= ""{}
        [GroupItem(Main)]_NormalScale("_NormalScale",range(0,10)) = 1

        [GroupItem(Main)]_DetailNormalMap("_DetailNormalMap",2d)=""{}
        [GroupItem(Main)]_DetailNormalScale("_DetailNormalScale",range(0,10)) = 1
        
        [Group(Env Light)]
        [GroupItem(Env Light)]_EnvMask("_EnvMask(R:MatcapMask,G:IBLMask)",2d) = "white"{}

        [GroupHeader(Env Light,Matcap)]
        [GroupItem(Env Light)]_MatCap("_MatCap",2d)=""{}
        [GroupItem(Env Light)]_MatCapScale("_MatCapScale",float) = 1

        [GroupHeader(Env Light,IBL)]
        [GroupToggle(Env Light)]_EnvMapOn("_EnvMapOn",float) = 0
        [GroupItem(Env Light)]_EnvMap("_EnvMap",cube) = ""{}
        [GroupItem(Env Light)]_EnvMapIntensity("_EnvMapIntensity",float) = 1
        [GroupItem(Env Light)]_EnvMapOffset("_EnvMapOffset",vector) = (0,0,0,0)
        [GroupItem(Env Light)]_Roughness("_Roughness",range(0,1)) = 0.5

        [Group(Settings)]
        [GroupHeader(Settings,BlendMode)]
        [GroupEnum(Settings,UnityEngine.Rendering.BlendMode)]_SrcMode("_SrcMode",int) = 1
        [GroupEnum(Settings,UnityEngine.Rendering.BlendMode)]_DstMode("_DstMode",int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Blend [_SrcMode][_DstMode]
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #include "PowerMatCapForwardPass.hlsl"

            ENDHLSL
        }
    }
}

