shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

// variable for controlling the amount of curvature on the corners of the screen
// lowering this value increases the amount of curvature
const float curvature = 8.0;
const float y_resolution = 270.0;
const float vignette_multiplier = 1.0;
const float blur_multiplier = 0.1;
const float scanline_brightness = 0.8;
const float scanline_intensity = 0.2;

// filter_linear_mipmap for slight bleed effect on pixels
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 centred_uv = SCREEN_UV * 2.0 - 1.0;
	vec2 uv_offset = centred_uv.yx / curvature;
	vec2 warped_uv = centred_uv + centred_uv * uv_offset * uv_offset;
	vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) * step(abs(warped_uv.y), 1.0));
	vec3 scanlines = vec3(sin(2.0 * warped_uv.y * y_resolution) * scanline_intensity + scanline_brightness);
	vec3 vignette = vec3(length(pow(abs(centred_uv), vec2(4.0)) / 3.0));
	
	vec3 screen_colour = textureLod(screen_texture, (warped_uv + 1.0) / 2.0, blur_multiplier).rgb * cutoff * scanlines;
	screen_colour -= vignette * vignette_multiplier;
	COLOR = vec4(screen_colour, 1.0);
}
