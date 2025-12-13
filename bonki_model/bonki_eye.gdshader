shader_type spatial;

uniform sampler2D texture_mask: source_color, filter_linear_mipmap;

uniform vec3 base_color: source_color;
uniform vec3 shine_color: source_color;
uniform vec3 shadow_color: source_color;

void fragment() {
	vec3 mask_sample = texture(texture_mask, UV).rgb;
	float base_weight = mask_sample.r;
	float shine_weight = mask_sample.g;
	float shadow_weight = mask_sample.b;	
	float weight_sum = base_weight + shine_weight + shadow_weight;
	
	vec3 output = (
		(base_color * base_weight) +
		(shine_color * shine_weight) +
		(shadow_color * shadow_weight)
	) / weight_sum;
	
	ALBEDO = output;
}

void light() {
	DIFFUSE_LIGHT = clamp(LIGHT_COLOR, 0.0, 1.0);
}
