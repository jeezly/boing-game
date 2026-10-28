shader_type spatial;
render_mode cull_disabled;
uniform vec4 paper_color : source_color = vec4(0.9, 0.3, 0.2, 1.0);
void fragment() {
	vec2 p = UV;
	vec2 cell = fract(p * vec2(6.0, 3.0)) - vec2(0.5);
	float hole = step(length(cell * vec2(1.0, 1.4)), 0.20);
	float border = step(0.09, p.x) * step(p.x, 0.91) * step(0.14, p.y) * step(p.y, 0.86);
	float scallop = step(0.93 + 0.04 * cos(p.x * 37.699), p.y);
	ALBEDO = paper_color.rgb;
	ROUGHNESS = 0.95;
	ALPHA = 1.0 - max(hole * border, scallop);
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
