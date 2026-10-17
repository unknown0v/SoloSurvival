extends Node3D
# Shared draw batches retain per-resource ownership for depletion/respawning.
var world
var batches: Dictionary = {}
var refs: Dictionary = {}
var pending: Dictionary = {}

func setup(owner_world) -> void:
	world = owner_world
	var stem := CylinderMesh.new()
	stem.bottom_radius = 1
	stem.top_radius = 0.267
	stem.height = 1
	stem.radial_segments = 9
	for id in world.nodes:
		var resource: Dictionary = world.nodes[id]
		if resource.kind!="tree":
			continue
		var body: Node3D = resource.body
		var bucket: String = str(floori(body.position.x/160))+":"+str(floori(body.position.z/160))
		var variant: int = int(id)%5
		var bark: Material = world.art.material("bark",Color("#66584a"))
		var leaves: Material = world.art.material("leaves"+str(variant%3),Color("#4e653f").lightened((variant%3)*0.04))
		append(id,bucket+":trunk",stem,bark,body.transform*Transform3D(Basis.IDENTITY.scaled(Vector3(0.3,6.4,0.3)),Vector3(0,3.2,0)),260)
		for i in range(4):
			var angle: float = i*2.399+variant
			var branch_basis := Basis.from_euler(Vector3(sin(angle)*0.7,0,cos(angle)*0.7)).scaled(Vector3(0.08,1.9,0.08))
			append(id,bucket+":branches",stem,bark,body.transform*Transform3D(branch_basis,Vector3(sin(angle)*0.55,4+i*0.4,cos(angle)*0.55)),140)
			var leaf_basis := Basis.IDENTITY.scaled(Vector3(1.9,1.7,1.9))
			append(id,bucket+":leaves"+str(variant%3),world.art.rock_mesh(0),leaves,body.transform*Transform3D(leaf_basis,Vector3(sin(angle)*1.3,5.2+i*0.5,cos(angle)*1.3)),360)
	for key in pending:
		var data: Dictionary = pending[key]
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = data.mesh
		multi.instance_count = data.entries.size()
		for i in range(data.entries.size()):
			var entry: Dictionary = data.entries[i]
			var visible_now: bool = float(world.nodes[entry.id].state.hp)>0
			multi.set_instance_transform(i,entry.transform if visible_now else hidden(entry.transform))
			if not refs.has(entry.id):
				refs[entry.id] = []
			refs[entry.id].append({"multi":multi,"index":i,"transform":entry.transform})
		var visual := MultiMeshInstance3D.new()
		visual.multimesh = multi
		visual.material_override = data.material
		visual.visibility_range_end = data.distance
		add_child(visual)
		batches[key] = visual
	pending.clear()

func append(id: String, key: String, mesh: Mesh, material: Material, transform: Transform3D, distance: float) -> void:
	if not pending.has(key):
		pending[key] = {"mesh":mesh,"material":material,"distance":distance,"entries":[]}
	pending[key].entries.append({"id":id,"transform":transform})

func hidden(transform: Transform3D) -> Transform3D:
	return Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO),transform.origin)

func show_resource(id: String, visible_now: bool) -> void:
	for entry in refs.get(id,[]):
		entry.multi.set_instance_transform(entry.index,entry.transform if visible_now else hidden(entry.transform))

func resource_visible(id: String) -> bool:
	if not refs.has(id):
		return false
	var entry: Dictionary = refs[id][0]
	return entry.multi.get_instance_transform(entry.index).basis.x.length()>0.01
