Shader "Character/PowerMatcap"
{
    Properties
    {
        [GroupHeader(v0.0.4)]
        [Group(Main)]
        [GroupHeader(Main,Main)]
        [GroupItem(Main)]_MainTex ("_MainTex", 2D) = "white" {}
        [GroupItem(Main)][hdr]_Color("_Color",color)=(1,1,1,1)

        [GroupHeader(Main,Normal)]
        [GroupToggle(Main,_NORMAL)]_NormalMapOn("_NormalMapOn",float) = 0
        [GroupItem(Main)]_NormalMap("_NormalMap",2d)= ""{}
        [GroupItem(Main)]_NormalScale("_NormalScale",range(0,10)) = 1

        [GroupItem(Main)]_DetailNormalMap("_DetailNormalMap",2d)=""{}
        [GroupItem(Main)]_DetailNormalScale("_DetailNormalScale",range(0,10)) = 1

        [Group(Surface)]
        [GroupToggle(Surface,_PBR_ON)]_PBROn("_PBROn",int) = 0
        [GroupItem(Surface)]_PbrMask("_PbrMask(R:Metallic,G:Smoothness,B:Occlusion)",2d)="white"{}
        [GroupItem(Surface)]_Metallic("_Metallic",range(0,1)) = 0.5
        [GroupItem(Surface)]_Smoothness("_Smoothness",range(0,1)) = 0.5
        [GroupItem(Surface)]_Occlusion("_Occlusion",range(0,1)) = 0
        [GroupToggle(Surface)]_IsSmoothnessReversed("_IsSmoothnessReversed",int) = 0
        
        [GroupHeader(Surface,mrt options)]
        [GroupItem(Surface,ssr use this)]_MRTSmoothness("_MRTSmoothness",range(0,1)) = 1
        
        [Group(Env Light)]
        [GroupItem(Env Light)][NoScaleOffset]_EnvMask("_EnvMask(R:MatcapMask,G:IBLMask)",2d) = "white"{}

        [GroupHeader(Env Light,Matcap)]
        [GroupItem(Env Light)]_MatCap("_MatCap",2d)=""{}
        [GroupItem(Env Light)]_MatCapScale("_MatCapScale",range(0,10)) = 1
        [GroupVectorSlider(Env Light,min max,0_1 0_1,,float)]_MatCapWidth("_MatCapWidth",vector) = (0,1,1,0)
        [GroupItem(Env Light)]_MatCapAngle("_MatCapAngle",range(0,360)) = 1

        [GroupHeader(Env Light,IBL)]
        [GroupItem(Env Light)][NoScaleOffset]_EnvMap("_EnvMap",cube) = ""{}
        [GroupItem(Env Light)]_EnvMapIntensity("_EnvMapIntensity",range(0,10)) = 0.5
        [GroupItem(Env Light)]_EnvMapOffset("_EnvMapOffset",vector) = (0,0,0,0)

        [GroupHeader(Env Light,Fresnel)]
        [GroupVectorSlider(Env Light,min max,0_1 0_1)]_FresnelWidth("_FresnelWidth",vector) = (0,1,0,0)
        [GroupItem(Env Light)][hdr]_FresnelColor("_FresnelColor",color)  =(1,1,1,1)

//================================================= emission
        [Group(Emission)]
        [GroupToggle(Emission,_EMISSION)]_EmissionOn("_EmissionOn",int) = 0
        [GroupItem(Emission)]_EmissionMap("_EmissionMap(rgb:Color,a:Mask)",2d)=""{}
        [hdr][GroupItem(Emission)]_EmissionColor("_EmissionColor(w:mask)",color) = (0,0,0,0)
//=================================================  weather
        [Group(Fog)]
        [GroupToggle(Fog)]_FogOn("_FogOn",int) = 1
        // [GroupToggle(Fog,SIMPLE_FOG,use simple linear depth height fog)]_SimpleFog("_SimpleFog",int) = 0
        [GroupToggle(Fog)]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(Fog)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(Fog)]_HeightFogOn("_HeightFogOn",int) = 1

        [Group(Shadow)]
        //[LineHeader(Shadows)]
        [GroupToggle(Shadow,_RECEIVE_SHADOWS_OFF)]_ReceiveShadowOff("_ReceiveShadowOff",int) = 0
        [GroupItem(Shadow)]_MainLightShadowSoftScale("_MainLightShadowSoftScale",range(0,1)) = 0.1

        [GroupHeader(Shadow,custom bias)]
        [GroupSlider(Shadow)]_CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0
        [GroupSlider(Shadow)]_CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0

        [Group(AdditionalLights)]
        [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHTS_ON)]_CalcAdditionalLights("_CalcAdditionalLights",int) = 0
        // [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHT_SHADOWS)]_ReceiveAdditionalLightShadow("_ReceiveAdditionalLightShadow",int) = 1
        // [GroupToggle(AdditionalLights,_ADDITIONAL_LIGHT_SHADOWS_SOFT)]_AdditionalIghtSoftShadow("_AdditionalIghtSoftShadow",int) = 0

        [Group(GI)]
        [GroupToggle(GI)]_CustomGIDiff("_CustomGIDiff",int) = 0
        [GroupItem(GI)]_GIDiffColor("_GIDiffColor",color) = (1,1,1,1)

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

        [GroupHeader(Alpha,Channel)]
        [GroupEnum(Alpha,r g b a,0 1 2 3)]_AlphaChannel("_AlphaChannel",int) = 3
// ================================================== StateSettings
        [Group(Settings)]
        [GroupEnum(Settings,UnityEngine.Rendering.CullMode)]_CullMode("_CullMode",int) = 2
		[GroupToggle(Settings)]_ZWriteMode("ZWriteMode",int) = 1
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[GroupEnum(Settings,UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4
// ================================================== stencil settings
        [Group(Stencil)]
		[GroupEnum(Stencil,UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 0
        [GroupItem(Stencil)]_Stencil ("Stencil ID", int) = 0
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)]_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255        
    }
    SubShader
    {
        LOD 100

        Pass
        {
            name "PowerMatCap"
            Tags { "LightMode"="UniversalForward" }
			
            ZWrite[_ZWriteMode]
			Blend [_SrcMode][_DstMode]
			// BlendOp[_BlendOp]
			Cull[_CullMode]
			ztest[_ZTestMode]

            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
            }

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma shader_feature _ADDITIONAL_LIGHTS_ON
            #pragma shader_feature _EMISSION

            #pragma vertex vert
            #pragma fragment frag

            // Material Keywords
            #pragma shader_feature_local_fragment ALPHA_TEST
            #pragma shader_feature _RECEIVE_SHADOWS_OFF
            #pragma shader_feature _PBR_ON
            #pragma shader_feature _NORMAL

            #define SMOOTH_FRESNEL
            #define MATCAP_UV_ROTATE
            #include "Lib/PowerMatCapInput.hlsl"
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
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #include "../../PowerShaderLib/Lib/UnityLib.hlsl"
            #include "Lib/PowerMatCapInput.hlsl"
            #define SHADOW_PASS
            #define _CustomShadowNormalBias _CustomShadowNormalBias
            #define _CustomShadowDepthBias _CustomShadowDepthBias
            #include "../../PowerShaderLib/URPLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }
    }
}

