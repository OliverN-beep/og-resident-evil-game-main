shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform sampler2D noise : repeat_enable, filter_nearest;

/* Water motion */
uniform vec2 noise_scroll = vec2(0.04, 0.03);
uniform float noise_scale = 2.0;
uniform float distortion_strength = 0.012;

/* Reflection */
uniform float reflection_strength : hint_range(0.0, 1.0) = 0.35;

/* Sparkles */
uniform float sparkle_strength : hint_range(0.0, 1.0) = 0.6;
uniform float sparkle_threshold = 0.92;
uniform float sparkle_speed = 2.5;

/* Color */
uniform vec4 water_tint : source_color = vec4(0.12, 0.32, 0.45, 1.0);

void fragment() {
	/* --- Noise for ripples --- */
	vec2 n_uv = UV * noise_scale + noise_scroll * TIME;
	float n = texture(noise, n_uv).r;

	/* Center noise around zero */
	float distortion = (n - 0.5) * distortion_strength;

	/* Distorted screen UV = top-down reflection */
	vec2 screen_uv = SCREEN_UV + distortion;

	vec4 reflection = texture(SCREEN_TEXTURE, screen_uv);

	/* Water absorbs light */
	reflection.rgb *= 0.85;

	/* --- Specular sparkles --- */
	float sparkle_noise = texture(
		noise,
		UV * noise_scale * 3.0 + TIME * sparkle_speed
	).r;

	float sparkle = step(sparkle_threshold, sparkle_noise);
	sparkle *= sparkle_strength;

	/* Slight blue-white sparkle color */
	vec3 sparkle_color = vec3(0.7, 0.85, 1.0) * sparkle;

	/* --- Final blend --- */
	vec4 water = water_tint;
	vec4 combined = mix(water, reflection, reflection_strength);

	combined.rgb += sparkle_color;

	COLOR = vec4(combined.rgb, 1.0);
}
