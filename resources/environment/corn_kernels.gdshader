shader_type spatial;
void fragment() {
	vec2 cell = fract(UV * vec2(12.0, 15.0));
	float kernel = smoothstep(0.02, 0.20, cell.x) * smoothstep(0.02,0.20,cell.y) * smoothstep(0.02,0.20,1.0-cell.x) * smoothstep(0.02,0.20,1.0-cell.y);
	ALBEDO = mix(vec3(0.65,0.31,0.035),vec3(1.0,0.77,0.17),kernel);
	ROUGHNESS = 0.55;
	NORMAL_MAP = vec3(0.5 + (cell.x-0.5)*0.2,0.5 + (cell.y-0.5)*0.2,1.0);
}
