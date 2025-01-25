#pragma disable_preprocessor
shader_type canvas_item;
// originally based on https://github.com/WittyCognomen/godot-psx-shaders-demo/blob/master/shaders/psx_dither_post.shader

uniform sampler2D dither_tex: hint_default_white, filter_nearest, repeat_enable;
uniform int col_depth = 32;
uniform bool dither_banding = false;
uniform bool enabled = true;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);

	vec2 dith_size = vec2(4, 4); // for GLES2: substitute for the dimensions of the dithering matrix
	vec2 buf_size = vec2(textureSize(SCREEN_TEXTURE,0));

	if (enabled) {
		vec3 dith = texture(dither_tex, SCREEN_UV*(buf_size/dith_size)).rgb;
		dith -= 0.5;
		COLOR.rgb = round(COLOR.rgb * float(col_depth) + dith * (dither_banding ? 1.0 : 0.0)) / float(col_depth);
	}
}