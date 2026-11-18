shader_type spatial;
render_mode unshaded, shadows_disabled, depth_draw_never;
void fragment() {
	vec2 edge = min(UV,1.0-UV);
	float opacity = smoothstep(0.0,0.18,edge.x) * smoothstep(0.0,0.18,edge.y);
	ALBEDO = vec3(0.12,0.15,0.12);
	ALPHA = opacity * 0.22;
}
