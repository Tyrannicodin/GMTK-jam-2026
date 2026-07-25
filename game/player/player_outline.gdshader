shader_type canvas_item;
uniform float outline_size = 0.05;
uniform vec3 outline_color: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 moved_texture_1 = texture(TEXTURE, UV - outline_size);
	vec4 moved_texture_2 = texture(TEXTURE, UV + outline_size);
	vec4 moved_texture_3 = texture(TEXTURE, vec2(UV.x - outline_size, UV.y + outline_size));
	vec4 moved_texture_4 = texture(TEXTURE, vec2(UV.x + outline_size, UV.y - outline_size));
	vec4 moved_texture_5 = texture(TEXTURE, vec2(UV.x + outline_size, UV.y));
	vec4 moved_texture_6 = texture(TEXTURE, vec2(UV.x - outline_size, UV.y));
	vec4 moved_texture_7 = texture(TEXTURE, vec2(UV.x, UV.y + outline_size));
	vec4 moved_texture_8 = texture(TEXTURE, vec2(UV.x, UV.y - outline_size));

	vec4 outline = vec4(moved_texture_1.rgb * 0.0, moved_texture_1.a) 
			+ vec4(moved_texture_2.rgb * 0.0, moved_texture_2.a) 
			+ vec4(moved_texture_3.rgb * 0.0, moved_texture_3.a) 
			+ vec4(moved_texture_4.rgb * 0.0, moved_texture_4.a) 
			+ vec4(moved_texture_5.rgb * 0.0, moved_texture_5.a) 
			+ vec4(moved_texture_6.rgb * 0.0, moved_texture_6.a) 
			+ vec4(moved_texture_7.rgb * 0.0, moved_texture_7.a) 
			+ vec4(moved_texture_8.rgb * 0.0, moved_texture_8.a);
	outline.rgb = outline_color;
	if (COLOR.a < 0.8) {
		COLOR = outline;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
