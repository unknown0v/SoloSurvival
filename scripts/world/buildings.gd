extends Node3D
const Settlement = preload("res://scripts/core/settlement.gd")
var game
var integrity: Dictionary = {}
var bodies: Dictionary = {}
var preview: Node3D
var candidate: Dictionary = {}
var placement_reason: String = ""
var build_kind: String = "foundation"
var edge: int = 0
var timer: float = 0
var good: StandardMaterial3D
var bad: StandardMaterial3D

func setup(owner_game) -> void:
	game = owner_game
	good = StandardMaterial3D.new()
	good.albedo_color = Color(0.2,0.9,0.6,0.4)
	good.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	good.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bad = good.duplicate()
	bad.albedo_color = Color(1,0.2,0.15,0.4)
	game.settlement.changed.connect(rebuild)
	rebuild()

static func origin(p: Dictionary) -> Vector3:
	return Vector3(float(p.cell[0])*3,float(p.y)+int(p.level)*3,float(p.cell[1])*3)

# Shared geometry drives rendering, collisions, and clearance checks.
static func boxes(p: Dictionary) -> Array:
	match p.kind:
		"foundation": return [[Vector3(0,-0.35,0),Vector3(2.98,0.7,2.98)]]
		"floor": return [[Vector3(0,-0.1,0),Vector3(2.98,0.2,2.98)]]
		"roof": return [[Vector3(0,0.12,0),Vector3(2.98,0.24,2.98)]]
		"half_wall": return [[Vector3(0,0.75,-1.5),Vector3(3,1.5,0.16)]]
		"window_frame": return [[Vector3(-1.05,1.5,-1.5),Vector3(0.9,3,0.16)],[Vector3(1.05,1.5,-1.5),Vector3(0.9,3,0.16)],[Vector3(0,2.65,-1.5),Vector3(1.2,0.7,0.16)],[Vector3(0,0.55,-1.5),Vector3(1.2,1.1,0.16)]]
		"stairs":
			var steps: Array = []
			for i in range(12):
				var h: float = (i+1)*0.25
				steps.append([Vector3(0,h*0.5,1.675-i*0.25),Vector3(1.1,h,0.25)])
			steps.append([Vector3(0,2.9,-1.5),Vector3(1.1,0.2,0.6)])
			return steps
		"bed": return [[Vector3(0,0.275,0),Vector3(1.2,0.55,2)]]
		"wall": return [[Vector3(0,1.5,-1.5),Vector3(3,3,0.16)]]
		"doorframe": return [[Vector3(-1.05,1.5,-1.5),Vector3(0.9,3,0.16)],[Vector3(1.05,1.5,-1.5),Vector3(0.9,3,0.16)],[Vector3(0,2.65,-1.5),Vector3(1.2,0.7,0.16)]]
		"door":
			return [[Vector3(-0.59,1.15,-0.91),Vector3(0.12,2.28,1.16)]] if p.open else [[Vector3(0,1.15,-1.5),Vector3(1.16,2.28,0.12)]]
		"cupboard": return [[Vector3(0,0.85,0),Vector3(0.8,1.7,0.8)]]
		"sleeping_bag": return [[Vector3(0,0.07,0),Vector3(0.85,0.14,1.8)]]
		"workbench": return [[Vector3(0,0.5,0),Vector3(1.4,1,0.75)]]
		"storage": return [[Vector3(0,0.38,0),Vector3(1.4,0.76,0.9)]]
		"campfire": return [[Vector3(0,0.18,0),Vector3(0.9,0.36,0.9)]]
		"furnace": return [[Vector3(0,0.65,0),Vector3(1.15,1.3,1.15)]]
	return []

func shape_transform(p: Dictionary, at: Vector3) -> Transform3D:
	var basis := Basis(Vector3.UP,-int(p.edge)*PI/2)
	return Transform3D(basis,origin(p)+basis*at)

func visual_piece(p: Dictionary, ghost: Material = null) -> Node3D:
	var body := StaticBody3D.new()
	body.position = origin(p)
	body.rotation.y = -int(p.edge)*PI/2
	body.set_meta("structure",p.id)
	var colors: Array = [Color("#9b875a"),Color("#876747"),Color("#8b918d"),Color("#67777d")]
	var mat: Material = ghost if ghost!=null else game.world.art.material("build"+str(p.tier),colors[int(p.tier)],0.55 if int(p.tier)==3 else 0)
	if p.kind=="furnace" and ghost==null:
		mat = game.world.art.material("furnace",Color("#77756e"))
	for box in boxes(p):
		var mesh := BoxMesh.new()
		mesh.size = box[1]
		var visual := MeshInstance3D.new()
		visual.mesh = mesh
		visual.position = box[0]
		visual.material_override = mat
		body.add_child(visual)
		if ghost==null and p.kind!="stairs":
			var collider := CollisionShape3D.new()
			var shape := BoxShape3D.new()
			shape.size = box[1]
			collider.shape = shape
			collider.position = box[0]
			body.add_child(collider)
	if ghost==null and p.kind=="stairs":
		var collider := CollisionShape3D.new()
		var ramp := ConvexPolygonShape3D.new()
		ramp.points = PackedVector3Array([Vector3(-0.55,0,1.8),Vector3(0.55,0,1.8),Vector3(-0.55,0,-1.8),Vector3(0.55,0,-1.8),Vector3(-0.55,3,-1.2),Vector3(0.55,3,-1.2),Vector3(-0.55,3,-1.8),Vector3(0.55,3,-1.8)])
		collider.shape = ramp
		body.add_child(collider)
	if ghost==null and p.kind in ["campfire","furnace"] and p.active:
		var flame := MeshInstance3D.new()
		var flame_mesh := SphereMesh.new()
		flame_mesh.radius = 0.17
		flame_mesh.height = 0.5
		flame.mesh = flame_mesh
		flame.position = Vector3(0,0.55 if p.kind=="campfire" else 1.4,0)
		var glow := StandardMaterial3D.new()
		glow.albedo_color = Color("#ffa954")
		glow.emission_enabled = true
		glow.emission = Color("#ff7722")
		flame.material_override = glow
		body.add_child(flame)
		var light := OmniLight3D.new()
		light.light_color = Color("#ffb268")
		light.light_energy = 0.8
		light.omni_range = 6
		light.position = flame.position
		body.add_child(light)
	if ghost!=null:
		body.collision_layer = 0
		body.collision_mask = 0
	return body

func rebuild() -> void:
	integrity = game.settlement.supports(game.settlement.pieces)
	for body in bodies.values():
		remove_child(body)
		body.queue_free()
	bodies.clear()
	for p in game.settlement.pieces:
		var body: Node3D = visual_piece(p)
		add_child(body)
		bodies[p.id] = body

func _physics_process(dt: float) -> void:
	if game==null or not game.ready_to_play:
		return
	timer -= dt
	if not game.build_mode or game.menu_open or game.paused:
		if preview!=null:
			preview.hide()
		return
	if timer>0:
		return
	timer = 0.15
	update_candidate()
	if preview!=null:
		remove_child(preview)
		preview.queue_free()
		preview = null
	if not candidate.is_empty():
		preview = visual_piece(candidate,good if placement_reason=="" else bad)
		add_child(preview)
	game.prompt = build_kind.to_upper()+"  /  "+("LEFT CLICK PLACE" if placement_reason=="" else placement_reason)+"\n1–9 PIECE   G NEXT TYPE   R ROTATE   B EXIT"

func update_candidate() -> void:
	candidate = {}
	placement_reason = "Aim at ground or a supported building socket."
	var camera: Camera3D = game.player.camera
	var query := PhysicsRayQueryParameters3D.create(camera.global_position,camera.global_position-camera.global_basis.z*5.5,1)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var point: Vector3 = hit.position
	var cell: Array = [roundi(point.x/3),roundi(point.z/3)]
	var level: int = 0
	var y: float = snappedf(game.world.math.height(cell[0]*3,cell[1]*3)+0.4,0.25)
	if hit.collider.has_meta("structure"):
		var target: Dictionary = game.settlement.find(str(hit.collider.get_meta("structure")))
		y = float(target.y)
		if build_kind!="foundation":
			cell = target.cell.duplicate()
			level = int(target.level)
			if build_kind in ["floor","roof"] and target.kind in Settlement.BEARING_WALLS:
				level += 1
			elif build_kind=="floor" and target.kind=="stairs":
				var step: Vector2i = Settlement.edge_step(int(target.edge))
				cell = [int(target.cell[0])+step.x,int(target.cell[1])+step.y]
				level += 1
	# Preserve the selected socket's base; otherwise prefer an exact cell over a neighbour.
	if not hit.collider.has_meta("structure") or build_kind=="foundation":
		var closest: int = 2
		for p in game.settlement.pieces:
			if p.kind!="foundation":
				continue
			var distance: int = absi(int(p.cell[0])-int(cell[0]))+absi(int(p.cell[1])-int(cell[1]))
			if distance<closest:
				y = float(p.y)
				closest = distance
	candidate = game.settlement.make_piece(build_kind,cell,y,level,edge)
	placement_reason = check_placement(candidate)

func check_placement(p: Dictionary) -> String:
	var location: Vector3 = origin(p)
	if game.player.global_position.distance_to(location)>6.5:
		return "Socket is out of reach."
	if absi(int(p.cell[0]))>100 or absi(int(p.cell[1]))>100 or int(p.level)>Settlement.MAX_LEVEL or float(p.y)<0 or float(p.y)>120:
		return "Outside the buildable island."
	if p.kind=="foundation":
		for dx in [-1.4,0,1.4]:
			for dz in [-1.4,0,1.4]:
				var h: float = game.world.math.height(location.x+dx,location.z+dz)
				if h<0.3 or float(p.y)-h>1.7 or h>float(p.y)+0.05:
					return "Foundation needs dry, flatter ground."
	if p.kind!="foundation":
		for dx in [-1.3,0,1.3]:
			for dz in [-1.3,0,1.3]:
				if game.world.math.height(location.x+dx,location.z+dz)>location.y+0.05:
					return "Terrain obstructs this socket."
	var reason: String = game.settlement.reason(p)
	if reason!="":
		return reason
	if clearance_blocked(p):
		return "Obstructed by a player, resource or structure."
	if not game.bag.can_pay(Settlement.COSTS[p.kind]):
		return "Missing resources: "+str(Settlement.COSTS[p.kind])
	return ""

func clearance_blocked(p: Dictionary, except_id: String = "") -> bool:
	for box in boxes(p):
		var shape := BoxShape3D.new()
		shape.size = box[1]-Vector3.ONE*0.06
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = shape
		query.transform = shape_transform(p,box[0])
		query.collision_mask = 3
		var hits: Array = get_world_3d().direct_space_state.intersect_shape(query,64)
		for hit in hits:
			var body: Object = hit.collider
			if body==game.player or body.has_meta("resource") or body.has_meta("corpse"):
				return true
			if body.has_meta("structure") and str(body.get_meta("structure"))!=except_id:
				var other: Dictionary = game.settlement.find(str(body.get_meta("structure")))
				var same: bool = Settlement.same_cell(p,other)
				var joint: bool = same and (
					(p.kind=="door" and other.kind=="doorframe" and p.edge==other.edge and p.level==other.level)
					or (p.kind in Settlement.WALLS and other.kind in Settlement.WALLS and p.edge!=other.edge and p.level==other.level)
					or (p.kind in ["floor","roof"] and other.kind in ["wall","doorframe"] and p.level==other.level+1)
					or (p.kind in ["wall","doorframe"] and other.kind in ["floor","roof"] and other.level==p.level+1))
				joint = joint or Settlement.landing_on_stairs(p,other) or Settlement.landing_on_stairs(other,p)
				if not joint:
					return true
	return false

func place() -> bool:
	update_candidate()
	if candidate.is_empty() or placement_reason!="":
		game.say(placement_reason)
		return false
	var placed: Dictionary = game.settlement.place(candidate,game.bag)
	if placed.is_empty():
		return false
	game.say("Built "+str(placed.kind)+" · "+str(Settlement.COSTS[placed.kind]))
	game.save_world(false)
	return true

func toggle_door(id: String) -> bool:
	var p: Dictionary = game.settlement.find(id)
	if p.is_empty() or p.kind!="door":
		return false
	var test: Dictionary = p.duplicate(true)
	test.open = not p.open
	if clearance_blocked(test,id):
		game.say("Door is obstructed.")
		return false
	p.open = not p.open
	game.settlement.changed.emit()
	game.save_world(false)
	return true
