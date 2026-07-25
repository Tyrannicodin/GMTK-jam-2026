shader_type canvas_item;
uniform float alpha;

void fragment() {
	if (COLOR.a > alpha) {
		COLOR.a = alpha;
	}
}