shader_type spatial;
render_mode diffuse_burley;
varying vec3 world;
void vertex() { world = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment() {
	float grain = sin(world.x*21.7+sin(world.z*12.3))*sin(world.z*23.6+world.x*9.5);
	ALBEDO = COLOR.rgb*(0.95+grain*0.06);
	ROUGHNESS = 0.93;
}
