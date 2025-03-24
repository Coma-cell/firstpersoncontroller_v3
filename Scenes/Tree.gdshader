shader_type spatial;

uniform float sway_speed : hint_range(0.1, 10.0) = 1.0;  // Speed of the sway.
uniform float sway_strength : hint_range(0.01, 0.1) = 0.05;  // Strength of the sway.
uniform float sway_phase_len : hint_range(1.0, 20.0) = 8.0;  // Phase length for sine wave sway.

uniform vec4 albedo_color :hint= vec4(1.0, 1.0, 1.0, 1.0);  // Color tint for the albedo.
uniform vec3 wind_direction : hint_normal = vec3(1.0, 0.0, 0.0);  // Wind direction (use a vector, e.g., vec3(1, 0, 0)).

void vertex() {
    // Sway based on the Y position, but we also add a factor of wind direction.
    float sway = sin(VERTEX.y * sway_phase_len + TIME * sway_speed) * sway_strength;

    // Apply sway to X and Z axes (branches or leaves sway in those directions).
    VERTEX.x += sway * wind_direction.x;  // Wind sway along the X axis.
    VERTEX.z += sway * wind_direction.z;  // Wind sway along the Z axis.

    // Optional: Add slight rotation for more organic movement.
    float twist = sin(VERTEX.y * 0.1 + TIME * 0.2) * 0.02;  // Apply slight twisting rotation to simulate more natural motion.
    mat4 rotation_matrix = mat4(1.0);
    rotation_matrix = rotation_matrix * rotate(twist, vec3(0.0, 1.0, 0.0));  // Rotate around the Y axis.
    VERTEX = (rotation_matrix * vec4(VERTEX.xyz, 1.0)).xyz;
}

void fragment() {
    // Sample the albedo texture.
    vec4 albedo_tex = texture(texture_albedo, UV);

    // Output the final color: texture color multiplied by the albedo color.
    ALBEDO = albedo_tex.rgb * albedo_color.rgb;
    ALPHA = albedo_tex.a * albedo_color.a;
}
