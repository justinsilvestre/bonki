shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D bg_tex : source_color;
uniform sampler2D noise_tex : source_color;

uniform float wobble_strength = 0.006;
uniform float wobble_speed = 0.15;

uniform float wash_amount = 0.20; // 0 = no wash, 1 = fully white

// Controls how much the noise modulates the wash (0 = uniform wash, 1 = fully noise-driven)
uniform float wash_noise_strength = 0.8;

// Noise scale for the wash pattern (higher = finer grain)
uniform float wash_noise_scale = 1.5;

void fragment() {
    vec2 uv = UV;

    // Scroll noise in 2 directions for “living paper” feel
    float n1 = texture(noise_tex, uv + vec2(TIME * wobble_speed, 0.0)).r;
    float n2 = texture(noise_tex, uv + vec2(0.0, TIME * wobble_speed * 0.7)).r;

    // Center around 0 then offset UV
    vec2 offset = (vec2(n1, n2) - 0.5) * wobble_strength;
    vec4 col = texture(bg_tex, uv + offset);

    // Use noise to make wash uneven (sample noise at a separate scale, optionally also animated)
    float wnoise = texture(
        noise_tex,
        uv * wash_noise_scale + vec2(TIME * wobble_speed * 0.35, TIME * wobble_speed * 0.22)
    ).r;

    // Map to [-1, 1] so it can either reduce or increase the local wash
    float wmod = (wnoise - 0.5) * 2.0;

    // Local wash amount (clamped to [0,1])
    float local_wash = clamp(wash_amount * (1.0 + wmod * wash_noise_strength), 0.0, 1.0);

    // White wash mix (uneven)
    col.rgb = mix(col.rgb, vec3(1.0), local_wash);

    ALBEDO = col.rgb;
    ALPHA = col.a;
}