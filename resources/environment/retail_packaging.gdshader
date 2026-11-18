shader_type spatial;
render_mode diffuse_burley;
uniform vec4 brand_color : source_color = vec4(0.8,0.2,0.1,1.0);
uniform sampler2D label_art : source_color, filter_linear_mipmap;
uniform int kind = 0;
void fragment() {
	vec2 uv = UV;
	vec3 color = brand_color.rgb;
	float band = step(0.26, uv.y) * step(uv.y, 0.73);
	if (kind == 1) {
		color *= 0.52 + 0.48 * smoothstep(0.0, 0.18, uv.y);
		vec2 print_uv = vec2(fract(uv.x * 2.0), 1.0 - (uv.y - 0.26) / 0.47);
		color = mix(color, texture(label_art, print_uv).rgb, band);
	} else {
		color = texture(label_art, kind == 2 ? fract(uv*vec2(3.0,2.0)) : uv).rgb;
		float fold = smoothstep(0.02,0.11,uv.x) * smoothstep(0.02,0.11,1.0-uv.x);
		color *= 0.88 + 0.12 * fold;
	}
	ALBEDO = color;
	ROUGHNESS = kind == 1 ? 0.24 : 0.65;
	SPECULAR = 0.45;
}
