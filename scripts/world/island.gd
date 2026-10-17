extends Node3D
const WorldMath = preload("res://scripts/core/world_math.gd")
const Forest = preload("res://scripts/world/forest.gd")
const Visuals = preload("res://scripts/world/visuals.gd")
var forest
var math = WorldMath.new()
var art = Visuals.new()
var game
var nodes: Dictionary = {}
var corpse_bodies: Array = []
var rng := RandomNumberGenerator.new()

func build(owner_game) -> void:
	game = owner_game
	forest = Forest.new()
	add_child(forest)
	rng.seed = WorldMath.SEED
	var terrain_mat := ShaderMaterial.new()
	terrain_mat.shader = preload("res://shaders/terrain.gdshader")
	for cz in range(8):
		for cx in range(8):
			chunk(cx,cz,terrain_mat)
		await get_tree().process_frame
	var ocean := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(1500,1500)
	ocean.mesh = plane
	var water := ShaderMaterial.new()
	water.shader = preload("res://shaders/water.gdshader")
	ocean.material_override = water
	add_child(ocean)
	for i in range(360):
		var x: float = rng.randf_range(-270,270)
		var z: float = rng.randf_range(-260,260)
		var h: float = math.height(x,z)
		if h<3 or h>80:
			continue
		var kind: String = "tree" if i<180 else "stone" if i<250 else "ore" if i<290 else "cloth" if i<325 else "berries"
		if kind=="tree" and (x>180 or z>200):
			continue
		resource(i,kind,x,z)
		if i%45==0:
			await get_tree().process_frame
	# Deterministic early resources in sight of the initial spawn.
	resource(500,"tree",-150,-159)
	var early: Array = ["stone","cloth","berries","tree","stone","ore"]
	for i in range(early.size()):
		resource(501+i,early[i],-143+(i%3)*6,-159-(i/3)*9)
	forest.setup(self)
	update_corpse()
	await get_tree().physics_frame

func chunk(cx: int, cz: int, mat: Material) -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	for z in range(21):
		for x in range(21):
			var wx: float = -320.0+cx*80+x*4
			var wz: float = -320.0+cz*80+z*4
			vertices.append(Vector3(wx,math.height(wx,wz),wz))
			normals.append(Vector3(math.height(wx-0.5,wz)-math.height(wx+0.5,wz),1,math.height(wx,wz-0.5)-math.height(wx,wz+0.5)).normalized())
			colors.append(math.biome(wx,wz))
	for z in range(20):
		for x in range(20):
			var i: int = z*21+x
			indices.append_array(PackedInt32Array([i,i+1,i+21,i+1,i+22,i+21]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = mat
	add_child(visual)
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	body.add_child(shape)
	add_child(body)

func resource(id: int, kind: String, x: float, z: float) -> void:
	var key: String = str(id)
	var body := StaticBody3D.new()
	body.position = Vector3(x,math.height(x,z),z)
	body.set_meta("resource",key)
	add_child(body)
	var shape := CollisionShape3D.new()
	var bounds := CylinderShape3D.new()
	if kind=="tree":
		bounds.radius = 0.42
		bounds.height = 6.4
		shape.position.y = 3.2
	elif kind in ["cloth","berries"]:
		for i in range(4):
			art.rock(body,Vector3(sin(i*2)*0.3,0.5+i*0.12,cos(i*2)*0.3),Vector3(0.4,0.55,0.4),art.material("hemp",Color("#527343")),i%3)
		if kind=="berries":
			for i in range(6):
				art.rock(body,Vector3(sin(i*1.8)*0.45,0.9,cos(i*1.8)*0.45),Vector3.ONE*0.09,art.material("berries",Color("#984d66")))
		bounds.radius = 0.6
		bounds.height = 1.5
		shape.position.y = 0.7
	else:
		art.rock(body,Vector3(0,0.5,0),Vector3(1.4,1.2,1.2),art.material(kind,Color("#8a9089") if kind=="stone" else Color("#9b805f")),id%5)
		bounds.radius = 1.25
		bounds.height = 1.8
		shape.position.y = 0.6
	shape.shape = bounds
	body.add_child(shape)
	var state: Dictionary = game.resource_data.get(key,{"hp":max_health(kind),"respawn":0.0})
	game.resource_data[key] = state
	nodes[key] = {"kind":kind,"body":body,"shape":shape,"state":state}
	body.rotation.y = rng.randf_range(0,TAU)
	set_resource_visible(key,float(state.hp)>0)

func max_health(kind: String) -> float:
	return 150.0 if kind=="tree" else 1.0 if kind in ["cloth","berries"] else 120.0

func set_resource_visible(id: String, shown: bool) -> void:
	nodes[id].body.visible = shown
	if forest!=null:
		forest.show_resource(id,shown)
	nodes[id].shape.set_deferred("disabled",not shown)

func harvest(id: String, tool: String) -> bool:
	var r: Dictionary = nodes[id]
	if float(r.state.hp)<=0:
		return false
	var kind: String = r.kind
	if kind not in ["cloth","berries"] and tool not in ["rock","axe","pickaxe"]:
		game.say("Select your rock or a crafted gathering tool.")
		return false
	var item: String = "wood" if kind=="tree" else kind
	var amount: int = 15 if kind=="tree" else 12
	if tool=="axe" and kind=="tree":
		amount = 45
	if tool=="pickaxe" and kind in ["stone","ore"]:
		amount = 36
	if kind=="cloth":
		amount = 15
	if kind=="berries":
		amount = 3
	var gathered: int = amount-game.bag.add(item,amount)
	if gathered<=0:
		game.say("Inventory full. Make room before gathering.")
		return false
	r.state.hp = maxf(0,float(r.state.hp)-(35.0 if tool in ["axe","pickaxe"] else 20.0)*gathered/amount)
	if kind in ["cloth","berries"]:
		r.state.hp = 0.0
	if float(r.state.hp)<=0:
		r.state.respawn = game.elapsed+600.0
		set_resource_visible(id,false)
	game.say("+%d %s" % [gathered,game.items.ITEMS[item].name])
	game.wear_tool()
	return true

func tick() -> void:
	for id in nodes:
		var r: Dictionary = nodes[id]
		if float(r.state.hp)<=0 and game.elapsed>=float(r.state.respawn):
			r.state.hp = max_health(r.kind)
			set_resource_visible(id,true)

func update_corpse() -> void:
	for old in corpse_bodies:
		if is_instance_valid(old):
			old.queue_free()
	corpse_bodies.clear()
	for corpse in game.corpses:
		var body := StaticBody3D.new()
		var p: Array = corpse.position
		body.position = Vector3(p[0],p[1],p[2])
		body.set_meta("corpse",corpse.id)
		add_child(body)
		corpse_bodies.append(body)
		art.crate(body)
		var shape := CollisionShape3D.new()
		var bounds := BoxShape3D.new()
		bounds.size = Vector3(1,0.7,0.8)
		shape.shape = bounds
		shape.position.y = 0.35
		body.add_child(shape)
