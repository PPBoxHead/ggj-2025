shader_type canvas_item;

uniform float value: hint_range(0.0, 100.0, 1.0);
uniform float speed;
uniform float wave_speed: hint_range(0.0, 10.0, 0.1);
uniform float wave_amp: hint_range(0.0, 10.0, 0.01);
uniform float intensity: hint_range(0.0, 10.0, 0.1);

void fragment() {
	float val2 = value / 100.0 + (sin((TIME + UV.x) + cos(TIME * 0.99 + UV.x) * wave_speed * 0.5) * wave_amp);
	COLOR = texture(TEXTURE, UV);
	if(UV.y < val2) {
		COLOR.a = 0.0;
	}
}