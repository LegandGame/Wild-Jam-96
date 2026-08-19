shader_type spatial;
render_mode cull_disabled;

uniform vec3 emissive_tint : source_color = vec3(1.0);
uniform vec3 tint_color : source_color = vec3(1.0);
uniform bool use_alpha = false;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D albedo_texture : source_color, hint_default_white;

uniform sampler2D orm_texture: hint_default_black;
uniform sampler2D emissive_texture: hint_default_black;
uniform sampler2D normal_texture: hint_normal;

uniform float emissive_strength = 2.0;
uniform float self_shadow_strength : hint_range(0.0, 1.0) = 0.5;
uniform float edge_softness : hint_range(0.0, 1.0) = 0.0;
uniform float rim_power = 10.0;
uniform float rim_brightness = 1.0;
uniform float rim_light_affect : hint_range(0.0, 1.0) = 0.25;
uniform vec3 rim_tint : source_color = vec3(1.0);

global uniform sampler2D reflection_texture;
global uniform sampler2D soft_reflection_texture;

varying lowp vec3 norm;

void vertex() {
	mat4 mat = MODELVIEW_MATRIX;
	norm = NORMAL;
	vec4 norm4 = vec4(norm.x, norm.y, norm.z, 0.0);
	norm4 = mat*norm4;
	norm = normalize(vec3(norm4.x, norm4.y, norm4.z));
}

void fragment() {
	vec3 orm = texture(orm_texture, UV).rgb;
	orm.g = 1.0 - orm.g;
	
	vec2 _norm = vec2(norm.x, norm.y/2.0);
	vec3 metal_specular = texture(reflection_texture, _norm).rgb;
	vec3 soft_specular = texture(soft_reflection_texture, _norm).rgb;
	
	vec3 fake_specular = mix(soft_specular, metal_specular, orm.b) * orm.g * 5.0;
	
	vec4 color = texture(albedo_texture, UV);
	vec3 albedo = color.rgb * tint_color;
	ALBEDO = albedo + (fake_specular * albedo);
	ALBEDO *= 1.0 - (max(0.0, orm.b - fake_specular.r) * 0.5);
	EMISSION = texture(emissive_texture, UV).rgb * emissive_tint * emissive_strength;
	NORMAL_MAP = texture(normal_texture, UV).xyz;
	if (use_alpha) {
		ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
		ALPHA = clamp(color.a, 0.0, 1.0);
	}
}

void light() {
	float lambert_diffuse = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	
	lambert_diffuse = smoothstep(0.0, edge_softness, lambert_diffuse);
	float attenuation = smoothstep(0.0, edge_softness, ATTENUATION);
	
	float rim = pow(1.0 - dot(VIEW, NORMAL), rim_power);
	rim = smoothstep(0.0, 0.01, rim) * lambert_diffuse * attenuation;
	
	vec3 light = LIGHT_COLOR * mix(1.0, lambert_diffuse, self_shadow_strength) * attenuation * (1.0 / PI);
	
	DIFFUSE_LIGHT += light;
	DIFFUSE_LIGHT += rim * rim_brightness * rim_tint * mix(vec3(1.0), LIGHT_COLOR, rim_light_affect);
}
