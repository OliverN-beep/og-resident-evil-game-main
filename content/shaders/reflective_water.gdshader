shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Basic water look
uniform sampler2D noise : repeat_enable;      // single seamless noise map
uniform vec2  noise_scroll = vec2(0.03, 0.03); // scrolling speed of the noise (XY)
uniform float noise_scale  = 1.0;              // tiling of the noise texture

// Reflection controls
uniform float reflection_strength : hint_range(0.0, 1.0) = 0.6; // mirror intensity
uniform float vertical_fade       : hint_range(0.0, 2.0) = 1.0; // how fast it fades with depth

// Distortion
uniform float distortion_amount : hint_range(0.0, 0.1) = 0.02; // how much the noise warps the reflection

// Colour tint
uniform vec4 tone_colour : source_color = vec4(0.6, 0.8, 1.0, 1.0);

// Optional zoom compensation (set from GDScript)
uniform float camera_scale = 1.0;

void fragment() {
	// Scrollable noise-based ripples
	vec2 n_uv = UV * noise_scale + noise_scroll * TIME;
	n_uv += vec2(sin(UV.y * 10.0 + TIME * 2.0), cos(UV.x * 10.0 + TIME * 1.5)) * 0.02;
	float n = texture(noise, n_uv).r; // 0‑1 value
	
	// Convert noise to distortion vector (centre around 0)
	vec2 distortion = vec2(n - 0.5) * distortion_amount / camera_scale;
	
	// Build reflected screen UV
	vec2 refl_uv = vec2(SCREEN_UV.x + distortion.x, SCREEN_UV.y - 2.0 * UV.y + distortion.y);
	vec4 reflection = texture(SCREEN_TEXTURE, refl_uv);
	
	// Fade with depth
	float fade = clamp(1.0 - UV.y * vertical_fade, 0.0, 1.0);
	
	// Fade with both vertical and horizontal UV
	float horiz_fade = clamp(1.0 - abs(UV.x - 0.5) * 2.0, 0.0, 1.0); // fade at sides
	float total_fade = fade * horiz_fade;
	
	// Base water tint
	vec4 water = tone_colour;
	
	// Darken based on depth
	water.rgb *= mix(1.0, 0.5, UV.y);
	
	// Combine
	COLOR = mix(water, reflection, reflection_strength * total_fade);
	COLOR.a = 1.0; // opaque water surface
}