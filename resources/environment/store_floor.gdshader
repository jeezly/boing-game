shader_type spatial;
varying vec3 world_point;
void vertex() {
	world_point = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	vec2 tile = world_point.xz / 2.0;
	vec2 edge = min(fract(tile), 1.0 - fract(tile));
	float seam = 1.0 - smoothstep(0.008, 0.018, min(edge.x, edge.y));
	float checker = mod(floor(tile.x) + floor(tile.y), 2.0);
	float wear = sin(world_point.x * 0.71) * sin(world_point.z * 1.03) * 0.012;
	vec3 interior = mix(vec3(0.64, 0.59, 0.49), vec3(0.69, 0.65, 0.55), checker);
	interior = mix(interior, vec3(0.38, 0.37, 0.32), seam * 0.6);
	bool outside = world_point.z > 0.0 || (world_point.z < -62.0 && world_point.x < -25.0);
	ALBEDO = (outside ? vec3(0.53, 0.54, 0.51) : interior) + vec3(wear);
	ROUGHNESS = outside ? 0.95 : 0.78;
}
