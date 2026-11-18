shader_type spatial;
varying vec3 world_point;
void vertex() { world_point = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
 vec2 tile = world_point.xz / 2.0;
 vec2 edge = min(fract(tile), 1.0 - fract(tile));
 float seam = 1.0 - smoothstep(0.004, 0.011, min(edge.x, edge.y));
 float checker = mod(floor(tile.x) + floor(tile.y), 2.0);
 vec3 ceramic = mix(vec3(0.79, 0.75, 0.64), vec3(0.84, 0.80, 0.70), checker);
 bool patio = world_point.z < -62.0 && world_point.x < -25.0;
 bool exterior = world_point.z > 0.0;
 bool produce = world_point.z < -62.0 && world_point.x > 25.0;
 bool cold = world_point.x < -53.0 && world_point.z < -18.0 && world_point.z > -61.0;
 bool checkout = world_point.z > -15.0 && world_point.z < -2.0;
 if (produce) ceramic = mix(ceramic, vec3(0.65, 0.73, 0.53), 0.28);
 if (cold) ceramic = mix(ceramic, vec3(0.50, 0.70, 0.69), 0.22);
 if (checkout) ceramic = mix(ceramic, vec3(0.80, 0.56, 0.36), 0.16);
 ceramic = mix(ceramic, vec3(0.53, 0.53, 0.46), seam * 0.35);
 ALBEDO = (exterior || patio) ? vec3(0.61, 0.64, 0.59) : ceramic;
 ROUGHNESS = (exterior || patio) ? 0.94 : 0.72;
}
