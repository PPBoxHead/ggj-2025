shader_type canvas_item;

uniform float value: hint_range(0.0, 100.0, 1.0);
uniform float speed;
uniform float wave_speed: hint_range(0.0, 10.0, 0.1);
uniform float wave_amp: hint_range(0.0, 10.0, 0.01);
uniform float intensity: hint_range(0.0, 10.0, 0.1);
uniform sampler2D noise_texture : hint_default_white;
uniform bool use_noise_overlay;

void fragment() {
	vec4 albedo_tex = texture(noise_texture, vec2(UV.x - TIME * (speed/2.0), UV.y - TIME * speed));
	float val2 = value / 100.0 + (sin((TIME + UV.x) * wave_speed) * wave_amp);
	COLOR = texture(TEXTURE, UV);
	if (use_noise_overlay) {
		COLOR *= albedo_tex * intensity;
	}
	if(UV.y < val2) {
		COLOR.a = 0.0;
	}
}