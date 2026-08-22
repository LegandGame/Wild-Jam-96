shader_type spatial;
render_mode unshaded, fog_disabled, depth_prepass_alpha, cull_disabled;

uniform float health : hint_range(0.0, 1.0) = 1.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

uniform vec3 healthy_color : source_color = vec3(0.0, 0.5, 0.75);
uniform vec3 hurt_color : source_color = vec3(0.75, 0.25, 0.15);

uniform sampler2D overlay_pattern : hint_default_black;
uniform vec2 uv_scale = vec2(1.0);
uniform float pattern_move_speed = 0.2;
uniform float pulse_on_weight = 1.0;
uniform float pulse_off_weight = 1.0;
uniform float pulse_speed = 1.0;
uniform float pulse_strength = 2.0;

global uniform sampler2D soft_reflection_texture;

float new_bounds(float from_min, float to_min, float from_max, float to_max, float value) {
	float from_distance = from_max - from_min;
	float to_distance = to_max - to_min;
	
	return to_min + ((value - from_min) / from_distance) * to_distance;
}

void fragment() {
	float fresnel = clamp(dot(VIEW, NORMAL), 0., 1.);
	fresnel = clamp(pow(1.0 - fresnel, 5.0), 0., 1.);
	
	float warble = smoothstep(0.0, 2.0, texture(soft_reflection_texture, (UV * 2.0) + TIME * 0.5).r);
	
	vec3 bubble_color = mix(hurt_color, healthy_color, health);
	ALBEDO = bubble_color + (bubble_color * pulse_strength * smoothstep(0.0, 1.0, new_bounds(-1.0, -pulse_off_weight, 1.0, pulse_on_weight, sin(TIME * pulse_speed))));
	ALBEDO += warble * ALBEDO * 1.5;
	ALPHA = fresnel + smoothstep(0.25, 1.0, texture(overlay_pattern, (UV * uv_scale) + TIME * pattern_move_speed).r) * smoothstep(0.25, 1.0, UV.y);
	ALPHA *= opacity;
}
