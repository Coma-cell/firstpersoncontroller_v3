shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx, depth_prepass_alpha;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float point_size : hint_range(0, 128) = 0;
uniform float roughness : hint_range(0, 1) = 1;
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;
uniform float specular = 0.13;
uniform float metallic = 0;
uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16, 16) = 1.5;
uniform sampler2D texture_backlight : hint_default_black, filter_linear_mipmap, repeat_enable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001);

uniform float sway_speed = 1.0;    // Controls swaying speed
uniform float sway_amount = 0.03;   // Controls swaying distance
uniform float sway_limit : hint_range(0.0, 1.0) = 0.5; // Limit sway influence (bottom part unaffected)

// Transparency control
uniform int alpha_mode : hint_enum("None", "Alpha Blend", "Alpha Scissor") = 0;
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.5; // Threshold for alpha scissor mode

void vertex() {
    // Limit sway influence to the top part of the sprite (by using Y position)
    float sway_factor = smoothstep(0.0, sway_limit, VERTEX.y); // Sway stronger at the top, weaker towards the bottom

    // Calculate sway based on time and vertex position
    float sway = sin(TIME * sway_speed + VERTEX.y) * sway_amount * sway_factor;

    // Apply sway only to x-axis
    VERTEX.x += sway * (VERTEX.y + 1.0);
}

void fragment() {
    vec2 base_uv = UV;
    vec4 albedo_tex = texture(texture_albedo, base_uv);
    ALBEDO = albedo.rgb * albedo_tex.rgb;

    float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
    METALLIC = metallic_tex * metallic;

    vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
    float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
    ROUGHNESS = roughness_tex * roughness;

    SPECULAR = specular;
    NORMAL_MAP = texture(texture_normal, base_uv).rgb;
    NORMAL_MAP_DEPTH = normal_scale;

    ALPHA *= albedo.a * albedo_tex.a;
    ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;

    // Apply transparency mode
    if (alpha_mode == 2) {
        // Alpha scissor mode
        if (ALPHA < alpha_threshold) {
            discard;  // Discard fragment if alpha is below the threshold
        }
    }

    // Set backlight
    vec3 backlight_tex = texture(texture_backlight, base_uv).rgb;
}