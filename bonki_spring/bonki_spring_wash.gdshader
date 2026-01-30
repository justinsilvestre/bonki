shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D bg_tex : source_color;
uniform sampler2D noise_tex : source_color;

uniform float wobble_strength = 0.006;
uniform float wobble_speed = 0.15;

uniform float wash_amount = 0.20; // 0 = no wash, 1 = fully white

void fragment() {
    vec2 uv = UV;

    // Scroll noise in 2 directions for “living paper” feel
    float n1 = texture(noise_tex, uv + vec2(TIME * wobble_speed, 0.0)).r;
    float n2 = texture(noise_tex, uv + vec2(0.0, TIME * wobble_speed * 0.7)).r;

    // Center around 0 then offset UV
    vec2 offset = (vec2(n1, n2) - 0.5) * wobble_strength;
    vec4 col = texture(bg_tex, uv + offset);

    // White wash mix
    col.rgb = mix(col.rgb, vec3(1.0), wash_amount);

    ALBEDO = col.rgb;
    ALPHA = col.a;
}
