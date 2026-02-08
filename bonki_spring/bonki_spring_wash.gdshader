shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D bg_tex : source_color;
uniform sampler2D noise_tex : source_color;

uniform float wobble_strength = 0.006;

// Added: Control movement via angle (in degrees) and a single speed value
uniform float movement_angle = 45.0; 
uniform float movement_speed = 0.15;

uniform float wash_amount = 0.20; 
uniform float wash_noise_strength = 0.8;
uniform float wash_noise_scale = 1.5;

void fragment() {
    vec2 uv = UV;

    // Convert degrees to radians for trigonometric functions
    float radians = movement_angle * (3.14159265359 / 180.0);
    
    // Create the direction vector from the angle
    vec2 direction = vec2(cos(radians), sin(radians));
    
    // Calculate final movement offset
    vec2 move_offset = direction * TIME * movement_speed;

    // Scroll noise using the calculated direction
    float n1 = texture(noise_tex, uv + move_offset).r;
    float n2 = texture(noise_tex, uv + (move_offset * 0.7)).r;

    // Center around 0 then offset UV
    vec2 offset = (vec2(n1, n2) - 0.5) * wobble_strength;
    vec4 col = texture(bg_tex, uv + offset);

    // Use noise to make wash uneven
    float wnoise = texture(
        noise_tex, 
        uv * wash_noise_scale + (move_offset * 0.35)
    ).r;

    float wmod = (wnoise - 0.5) * 2.0;
    float local_wash = clamp(wash_amount * (1.0 + wmod * wash_noise_strength), 0.0, 1.0);

    col.rgb = mix(col.rgb, vec3(1.0), local_wash);

    ALBEDO = col.rgb;
    ALPHA = col.a;
}