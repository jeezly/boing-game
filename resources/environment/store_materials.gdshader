shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color = vec4(0.65,0.40,0.2,1.0);
uniform int material_kind = 0;
varying vec3 point;
void vertex() { point = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment() {
	float grain;
	if (material_kind == 0) {
		float line = point.y*80.0 + sin(point.x*1.9+point.z*2.7)*2.2;
		grain = sin(line)*0.032 + sin(line*2.9)*0.013;
	} else {
		grain = (fract(sin(dot(floor(point*18.0),vec3(12.98,78.23,37.72)))*43758.54)-0.5)*0.022;
	}
	ALBEDO = clamp(base_color.rgb + grain,vec3(0.0),vec3(1.0));
	ROUGHNESS = material_kind == 2 ? 0.48 : 0.87;
	METALLIC = material_kind == 2 ? 0.12 : 0.0;
}
