shader_type canvas_item;
uniform sampler2D tex;

void fragment() {
	COLOR = (COLOR - 0.1) * (texture(tex, (UV) / 2. + sin(floor(TIME * 4.)) * 0.2 + vec2(0.0,0.2)) * 1.4);
}
