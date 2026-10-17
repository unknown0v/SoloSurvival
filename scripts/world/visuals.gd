extends RefCounted
var materials: Dictionary = {}
var rocks: Dictionary = {}

func material(id: String, color: Color, metallic: float = 0.0) -> StandardMaterial3D:
	if materials.has(id):
		return materials[id]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	mat.metallic = metallic
	if id in ["bark","stone","wood"]:
		var image := Image.create(64,64,false,Image.FORMAT_RGB8)
		for y in range(64):
			for x in range(64):
				var grain: float = sin(x*1.9+sin(y*0.16)*1.8) if id in ["wood","bark"] else sin(x*17+y*31)*sin(y*11+x*7)
				var v: float = 0.87+grain*0.10
				image.set_pixel(x,y,Color(v,v,v))
		image.generate_mipmaps()
		mat.albedo_texture = ImageTexture.create_from_image(image)
		mat.uv1_triplanar = true
		mat.uv1_scale = Vector3(0.8,0.8,0.8)
	materials[id] = mat
	return mat

func rock_mesh(variant: int) -> ArrayMesh:
	if rocks.has(variant):
		return rocks[variant]
	var sphere := SphereMesh.new()
	sphere.radius = 1
	sphere.height = 2
	sphere.radial_segments = 12
	sphere.rings = 7
	var arrays: Array = sphere.get_mesh_arrays()
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	for i in range(vertices.size()):
		var p: Vector3 = vertices[i]
		p *= 0.9+sin(p.x*9+variant*2.8)*sin(p.z*7+p.y*3.7)*0.16
		p.y = maxf(p.y,-0.65)
		vertices[i] = p
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	rocks[variant] = mesh
	return mesh

func rock(parent: Node3D, at: Vector3, size: Vector3, mat: Material, variant: int = 0) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	visual.mesh = rock_mesh(variant)
	visual.position = at
	visual.scale = size
	visual.material_override = mat
	parent.add_child(visual)
	return visual

func cylinder(parent: Node3D, at: Vector3, radius: float, height: float, mat: Material, top: float = -1) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = radius
	mesh.top_radius = radius if top<0 else top
	mesh.height = height
	mesh.radial_segments = 9
	visual.mesh = mesh
	visual.material_override = mat
	visual.position = at
	parent.add_child(visual)
	return visual

func crate(parent: Node3D) -> void:
	var wood: Material = material("wood",Color("#92724d"))
	var iron: Material = material("iron",Color("#424c4e"),0.6)
	for i in range(5):
		var plank := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.18,0.6,0.72)
		plank.mesh = mesh
		plank.material_override = wood
		plank.position = Vector3((i-2)*0.19,0.3,0)
		parent.add_child(plank)
	for x in [-0.32,0.32]:
		var band := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.07,0.64,0.77)
		band.mesh = mesh
		band.material_override = iron
		band.position = Vector3(x,0.32,0)
		parent.add_child(band)
