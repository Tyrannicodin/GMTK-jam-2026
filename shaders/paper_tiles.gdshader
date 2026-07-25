shader_type canvas_item;
uniform sampler2D tex;

void fragment() {
	vec2 new_uv = fract(UV / 3. + sin(floor(TIME * 2.)) * 0.4);
	COLOR = (COLOR - 0.02) * (texture(tex, new_uv) * 1.3);
}
