shader_type spatial;
render_mode unshaded;

uniform float sway_speed = 1.0;
uniform float sway_strength = 0.05;
uniform float sway_phase_len = 8.0;

void vertex() {
    float sway = sin(VERTEX.y * sway_phase_len + TIME * sway_speed) * sway_strength;
    VERTEX.x += sway;
    VERTEX.z += sway;
}

void fragment() {
    ALBEDO = vec3(0.0, 1.0, 0.0); // Green color for leaves, change this to your texture or color
}
