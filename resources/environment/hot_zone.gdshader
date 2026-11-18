shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, blend_mix, depth_draw_never;
uniform bool pillar = false;
void fragment() {
	float pulse = 0.85 + 0.15 * sin(TIME * 3.0);
	float bands = pillar ? (0.32 + 0.25 * pow(abs(sin(UV.y * 38.0 - TIME * 3.0)), 8.0)) : 1.0;
	ALBEDO = vec3(1.0, 0.004, 0.015) * pulse;
	EMISSION = ALBEDO * 0.45;
	ALPHA = bands * (pillar ? 0.42 : 0.95);
}
