shader_type spatial;
uniform sampler2D water_normal_noise;
uniform vec3 water_color:source_color;
uniform float time_scale:hint_range(0.0, 10.0, 0.25);
uniform float UV_scale:hint_range(0.0, 10.0, 0.25);
uniform sampler2D screen_texture :hint_screen_texture, repeat_disable;
uniform sampler2D sun_highlight;
uniform vec2 abberation_r;
uniform vec2 abberation_g;
uniform vec2 abberation_b;
uniform float time_scale_highlight=1.0;
uniform float normal:hint_range(0.0, 10.0, 0.1)=0.5;
uniform float roughness:hint_range(0.0, 10.0, 0.1)=0.25;



vec3 Soft_Light(vec3 base, vec3 blend){
	vec3 limit = step(0.5,blend);
	return mix(2.0 * base* blend + base * base * (1.0 -2.0 *blend),
		sqrt(base) * (2.0 * blend -1.0) + (2.0 *base) * (1.0 - blend), limit);
}


void fragment() {
	vec2 _uv = UV*UV_scale;
	vec2 _suv=SCREEN_UV;

	_uv.x += sin(TIME*time_scale + (_uv.x + _uv.y) * 25.0 ) * 0.01;
	_uv.y += cos(TIME*time_scale + (_uv.x - _uv.y) * 25.0 ) * 0.01;

	_suv.x += sin(TIME*time_scale + (_suv.x + _suv.y) * 25.0 ) * 0.01;
	_suv.y += cos(TIME*time_scale + (_suv.x - _suv.y) * 25.0 ) * 0.01;

	float r=texture(sun_highlight,_uv+abberation_r+TIME* time_scale_highlight).r;
	float g=texture(sun_highlight,_uv+abberation_g+TIME* time_scale_highlight).g;
	float b=texture(sun_highlight,_uv+abberation_b+TIME* time_scale_highlight).b;




	vec3 blended= Soft_Light( texture(screen_texture, _suv).rgb,vec3(r,g,b));

	ALBEDO=blended;
	NORMAL_MAP=texture(water_normal_noise,_uv).rgb;
	NORMAL*= normal;
	ROUGHNESS=roughness;



}