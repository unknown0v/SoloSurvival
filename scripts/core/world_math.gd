extends RefCounted
const SEED: int = 197403
const SIZE: float = 640.0
const SPAWN = Vector3(-150, 0, -155)
var samples: Dictionary = {}
var noise := FastNoiseLite.new()

func _init() -> void:
	noise.seed = SEED
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.012
	noise.fractal_octaves = 4

# Match the exact 4 m triangles rendered and collided by island.gd.
# Vertex heights/seed are unchanged; consumers now share the physical surface.
func sample_vertex(x: int, z: int) -> float:
	var key := Vector2i(x,z)
	if not samples.has(key):
		samples[key] = raw_height(x*4.0,z*4.0)
	return float(samples[key])

func height(x: float, z: float) -> float:
	var gx: int = floori(x/4.0)
	var gz: int = floori(z/4.0)
	var fx: float = x/4.0-gx
	var fz: float = z/4.0-gz
	var a: float = sample_vertex(gx,gz)
	if is_zero_approx(fx) and is_zero_approx(fz):
		return a
	var b: float = sample_vertex(gx+1,gz)
	var c: float = sample_vertex(gx,gz+1)
	if fx+fz<=1:
		return a+(b-a)*fx+(c-a)*fz
	var d: float = sample_vertex(gx+1,gz+1)
	return d+(c-d)*(1-fx)+(b-d)*(1-fz)

func raw_height(x: float, z: float) -> float:
	var radius: float = Vector2(x/290.0, z/280.0).length()
	var coast: float = 1.0-smoothstep(0.68, 1.04, radius)
	var mountain: float = exp(-((x+35.0)*(x+35.0)/11000.0+(z-120.0)*(z-120.0)/8500.0))*72.0
	var base: float = -9.0+coast*(22.0+noise.get_noise_2d(x,z)*11.0+mountain)
	var river: float = (1.0-smoothstep(3.0,9.0,absf(x-river_x(z))))*(1.0-smoothstep(90.0,145.0,z))
	return lerpf(base, -1.1, river*coast)

func river_x(z: float) -> float:
	return 45.0+sin(z*0.021)*26.0

func freshwater(x: float, z: float) -> bool:
	return z < 110 and absf(x-river_x(z)) < 6 and height(x,z) < 0.7

func biome(x: float, z: float) -> Color:
	var h: float = height(x,z)
	var gradient: float = Vector2(height(x+2,z)-height(x-2,z),height(x,z+2)-height(x,z-2)).length()/4
	var base: Color = Color("#6a7753").lerp(Color("#b4a47d"),1.0-smoothstep(2.0,9.0,h))
	base = base.lerp(Color("#b0966d"),smoothstep(100.0,205.0,x)*(1.0-smoothstep(60.0,140.0,z)))
	base = base.lerp(Color("#808680"),smoothstep(0.5,1.0,gradient))
	base = base.lerp(Color("#d7e1dd"),maxf(smoothstep(57.0,80.0,h),smoothstep(155.0,240.0,z)))
	return base*(0.92+(noise.get_noise_2d(x*8,z*8)+1.0)*0.06)
