shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color = vec4(0.5,0.25,0.1,1.0);
uniform int surface_kind = 0;
varying vec3 local_point;
void vertex() { local_point = VERTEX; }
void fragment() {
	float grain;
	if (surface_kind == 0) {
		float wave = local_point.x * 65.0 + sin(local_point.y * 3.0 + local_point.x * 5.0) * 2.0;
		grain = sin(wave) * 0.045 + sin(wave * 3.1) * 0.018;
	} else if (surface_kind == 1) {
		grain = sin(local_point.x * 230.0) * sin(local_point.y * 220.0) * 0.035;
	} else {
		grain = fract(sin(dot(floor(local_point * 120.0), vec3(12.9898,78.233,34.15))) * 43758.5453) * 0.10 - 0.05;
	}
	ALBEDO = clamp(base_color.rgb + grain, vec3(0.0), vec3(1.0));
	ROUGHNESS = 0.9;
}
