shader_type canvas_item;
uniform sampler2D tex;
uniform float scale = 3.;
uniform float speed = 2.;

void fragment() {
	vec2 new_uv = fract(UV / scale + sin(floor(TIME * speed)) * 0.4);
	COLOR = (COLOR - 0.02) * (texture(tex, new_uv) * 1.3);
}
