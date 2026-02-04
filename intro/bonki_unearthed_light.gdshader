shader_type spatial;
render_mode unshaded, cull_front;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    float world_depth = texture(depth_texture, SCREEN_UV).x;
    float pillar_depth = FRAGCOORD.z;
	vec3 original_world = texture(screen_texture, SCREEN_UV).rgb;

    // If world_depth is LESS than pillar_depth, 
    // it means there is an object closer to the camera 
    // than the back-wall of our cylinder.
    if (world_depth < pillar_depth - 0.0001) {
    	ALBEDO = mix(original_world, light_color.rgb, light_color.a); // e.g. white silhouette
        ALPHA = 1.0;
    } else {
		discard;
    }
}