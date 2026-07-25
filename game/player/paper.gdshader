shader_type canvas_item;

uniform vec4 border_color: source_color;
uniform float radius = 30;
uniform int samples = 15;
uniform sampler2D paper_texture;

float draw_outline(float offset, vec2 uv, sampler2D tex, vec2 texture_pixel_size) {
	float r = radius;
	float d = 0.0;
	for (int i = 0; i < samples; i++) {
		float angle = (2.0 * PI / float(samples)) * float(i);
		vec2 point = vec2(uv.x + cos(angle) * r * texture_pixel_size.x, uv.y + sin(angle) * r * texture_pixel_size.y);
		d += texture(tex, point).a;
		if (d >= 0.1) {
			return clamp(1.0, 0,1);
		}
    }
	return 0.0;
}

void fragment(){
	if (COLOR.a < 0.9) {
		vec4 tex = texture(TEXTURE, UV);
		float outline = draw_outline(0, UV, TEXTURE, TEXTURE_PIXEL_SIZE);
		COLOR = vec4(
			border_color.rgb,
			outline
		);
	}
	
	COLOR = (COLOR - 0.1) * (texture(paper_texture, (UV) / 2. + sin(floor(TIME * 4.)) * 0.2 + vec2(0.0,0.2)) * 1.4);
}