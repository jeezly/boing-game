shader_type spatial;
uniform vec4 power_tint : source_color = vec4(1.0);
uniform float power_mix = 0.0;
uniform float ghost_alpha = 1.0;
varying vec3 local_position;
void vertex() { local_position = VERTEX; }
void fragment() {
	float warmth = smoothstep(-0.5,0.5,local_position.y);
	vec3 orange = vec3(0.95,0.34,0.035);
	vec3 yellow = vec3(1.0,0.67,0.09);
	float face = 1.0-smoothstep(-0.3,0.05,local_position.z);
	vec3 skin = mix(orange,yellow,clamp(warmth*0.72+face*0.22,0.0,1.0));
	ALBEDO = mix(skin,power_tint.rgb,power_mix);
	ROUGHNESS = 0.72;
	ALPHA = ghost_alpha;
}
