shader_type spatial;
render_mode cull_disabled;

uniform vec3 emissive_tint : source_color = vec3(1.0);
uniform vec3 tint_color : source_color = vec3(1.0);
uniform bool use_alpha = false;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0) = 0.5;

uniform bool use_triplanar = false;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform sampler2D orm_texture: hint_default_white;
uniform sampler2D emissive_texture: hint_default_black;
uniform sampler2D normal_texture: hint_normal;

uniform float metallic = 1.0;
uniform float roughness = 1.0;

uniform float normal_strength = 1.0;
uniform float emissive_strength = 2.0;
uniform float self_shadow_strength : hint_range(0.0, 1.0) = 0.5;
uniform float edge_softness : hint_range(0.0, 1.0) = 0.0;
uniform float rim_power = 10.0;
uniform float rim_brightness = 1.0;
uniform float rim_light_affect : hint_range(0.0, 1.0) = 0.25;
uniform vec3 rim_tint : source_color = vec3(1.0);

global uniform sampler2D reflection_texture;
global uniform sampler2D soft_reflection_texture;

varying lowp vec3 projected_normal;
varying vec3 world_pos;
varying vec3 world_normal;

vec4 sample_triplanar(sampler2D sample_texture, vec3 pos, vec3 normal, vec2 tiling_scale, vec2 tiling_offset) {
	vec3 blend_weights = abs(normal);
	blend_weights = normalize(max(blend_weights, 0.00001));
	
	vec2 uv_x = pos.zy * tiling_scale;
	vec2 uv_y = pos.xz * tiling_scale;
	vec2 uv_z = pos.xy * tiling_scale;
	
	vec3 sample_x = texture(sample_texture, uv_x).rgb;
	vec3 sample_y = texture(sample_texture, uv_y).rgb;
	vec3 sample_z = texture(sample_texture, uv_z).rgb;
	
	return vec4((sample_x * blend_weights.x)
		+ (sample_y * blend_weights.y)
		+ (sample_z * blend_weights.z), 
		1.0);
}

vec4 get_texture(sampler2D sampler, vec2 uv) {
	if (use_triplanar) {
		return sample_triplanar(sampler, world_pos, world_normal, uv_scale, uv_offset);
	}
	
	return texture(sampler, (uv * uv_scale) + uv_offset);
}

void vertex() {
	projected_normal = normalize(MODELVIEW_NORMAL_MATRIX * NORMAL);
	
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = MODEL_NORMAL_MATRIX * NORMAL;
}

void fragment() {
	vec3 orm = get_texture(orm_texture, UV).rgb;
	orm.b *= metallic;
	orm.g = 1.0 - (orm.g * roughness);
	
	vec2 reflection_normal = projected_normal.xy * vec2(1.0, 0.5);
	vec3 metal_specular = texture(reflection_texture, reflection_normal).rgb;
	vec3 soft_specular = texture(soft_reflection_texture, reflection_normal).rgb;
	
	vec3 fake_specular = clamp(mix(soft_specular, metal_specular, orm.b) * orm.g * 5.0, vec3(0.0), vec3(5.0));
	
	vec4 color = get_texture(albedo_texture, UV);
	vec3 albedo = color.rgb * tint_color;
	ALBEDO = albedo + (fake_specular * albedo);
	ALBEDO *= 1.0 - (max(0.0, orm.b - fake_specular.r) * 0.5);
	EMISSION = get_texture(emissive_texture, UV).rgb * emissive_tint * emissive_strength;
	NORMAL_MAP = get_texture(normal_texture, UV).xyz;
	NORMAL_MAP_DEPTH = normal_strength;
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
