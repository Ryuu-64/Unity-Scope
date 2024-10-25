Shader "Custom/ScopeShader"
{
    Properties
    {
        field_of_view ("Field Of View", Range(0,180)) = 4.5
        effective_field_of_view ("Effective Field Of View", Range(0,180)) = 3.5
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float field_of_view;
        float effective_field_of_view;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        // dot(A,B)=∣A∣⋅∣B∣⋅cos(θ)
        // ∣A∣=1
        // ∣B∣=1
        // dot(A,B)=cos(θ)
        // θ=acos(dot(A,B))
        float get_angle_between(Input IN, inout SurfaceOutputStandard o)
        {
            float3 normalize_view_dir = normalize(IN.viewDir);
            float cos_radians = dot(normalize_view_dir, o.Normal);
            return acos(cos_radians);
        }

        float get_view_dir_factor_from_angle(
            float effective_field_of_view, float field_of_view,
            float angle_between
        )
        {
            float angle_between_degrees = degrees(angle_between);
            float visible_bound_factor = step(angle_between_degrees, effective_field_of_view);

            float exclude_visible_bound_factor = step(effective_field_of_view, angle_between_degrees);
            float smooth_invisible_bound_factor =
                smoothstep(field_of_view, effective_field_of_view, angle_between_degrees);
            float invisible_bound_factor = exclude_visible_bound_factor * smooth_invisible_bound_factor;

            return visible_bound_factor + invisible_bound_factor;
        }

        float get_view_dir_factor(Input IN, inout SurfaceOutputStandard o)
        {
            float angle_between = get_angle_between(IN, o);
            float view_dir_factor = get_view_dir_factor_from_angle(
                effective_field_of_view, field_of_view,
                angle_between
            );
            return view_dir_factor;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            o.Albedo = c.rgb;

            float view_dir_factor = get_view_dir_factor(IN, o);
            o.Albedo *= view_dir_factor;

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}