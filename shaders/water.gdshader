shader_type spatial;
render_mode blend_mix, cull_disabled;
varying vec3 world;
void vertex() { world = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment() {
	float waves = sin(world.x*0.65+TIME*0.8)+sin(world.z*0.82-TIME);
	NORMAL = normalize(NORMAL+vec3(sin(world.x+TIME)*0.075,cos(world.z-TIME)*0.075,0.0));
	ALBEDO = mix(vec3(0.07,0.23,0.25),vec3(0.16,0.34,0.36),waves*0.2+0.5);
	METALLIC = 0.15;
	ROUGHNESS = 0.25;
	ALPHA = 0.92;
}
