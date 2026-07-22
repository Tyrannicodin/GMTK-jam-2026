shader_type canvas_item;

instance uniform float intensity: hint_range(0.0, 1.0, 0.01) = 0.0;
const vec3 WHITE = vec3(1., 1., 1.);

void fragment(){
	COLOR = vec4(mix(COLOR.rgb, WHITE.rgb, intensity), COLOR.a);
}
