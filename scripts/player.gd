extends CharacterBody3D
var game
var camera: Camera3D
var head: Node3D
var model: Node3D
var capsule: CapsuleShape3D
var body_shape: CollisionShape3D
var standing_probe: CapsuleShape3D
var crouched: bool = false
var torch_light: OmniLight3D
var pitch: float = 0
var sensitivity: float = 0.002
var swing: float = 0
var bob: float = 0
var current_item: String = ""
var cooldown: float = 0
var swimming: bool = false
var hit: Dictionary = {}

func setup(owner_game, at: Vector3, yaw: float, look: float) -> void:
	game = owner_game
	collision_layer = 2
	collision_mask = 1
	position = at
	rotation.y = yaw
	pitch = look
	capsule = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.8
	body_shape = CollisionShape3D.new()
	body_shape.shape = capsule
	body_shape.position.y = 0.9
	add_child(body_shape)
	standing_probe = CapsuleShape3D.new()
	standing_probe.radius = 0.29
	standing_probe.height = 1.73
	head = Node3D.new()
	head.position.y = 1.65
	add_child(head)
	camera = Camera3D.new()
	camera.near = 0.06
	camera.far = 900
	camera.fov = 78
	head.add_child(camera)
	camera.current = true
	model = Node3D.new()
	camera.add_child(model)
	model.position = Vector3(0.28,-0.28,-0.48)
	torch_light = OmniLight3D.new()
	torch_light.light_color = Color("#ffb76b")
	torch_light.light_energy = 2.4
	torch_light.omni_range = 12
	torch_light.position = Vector3(0.2,0,-0.3)
	camera.add_child(torch_light)

func _unhandled_input(event: InputEvent) -> void:
	if game==null or not game.ready_to_play:
		return
	if event is InputEventMouseMotion and game.playing and not game.menu_open and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		rotation.y = wrapf(rotation.y-event.screen_relative.x*sensitivity,-PI,PI)
		pitch = clampf(pitch-event.screen_relative.y*sensitivity,-1.45,1.45)
	if event is InputEventMouseButton and event.pressed and game.playing and not game.menu_open and not game.paused:
		if event.button_index==MOUSE_BUTTON_LEFT and cooldown<=0:
			cooldown = 0.65
			game.primary_action()
		elif event.button_index==MOUSE_BUTTON_WHEEL_UP:
			game.select_slot(posmod(game.selected-1,6))
		elif event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
			game.select_slot((game.selected+1)%6)

func _physics_process(dt: float) -> void:
	if game==null or not game.ready_to_play:
		return
	update_model(dt)
	if not game.playing or game.paused or float(game.stats.health)<=0:
		velocity = Vector3.ZERO
		return
	dt = minf(dt,0.1)
	var blocked: bool = game.menu_open
	var crouch: bool = crouched if blocked else Input.is_physical_key_pressed(KEY_CTRL)
	if not crouch and crouched:
		var clearance := PhysicsShapeQueryParameters3D.new()
		clearance.shape = standing_probe
		clearance.transform = Transform3D(Basis.IDENTITY,global_position+Vector3.UP*0.93)
		clearance.collision_mask = 1
		clearance.exclude = [get_rid()]
		crouch = not get_world_3d().direct_space_state.intersect_shape(clearance,1).is_empty()
	crouched = crouch
	capsule.height = 1.2 if crouch else 1.8
	body_shape.position.y = capsule.height*0.5
	var direction := Vector3.ZERO
	if not blocked and Input.is_physical_key_pressed(KEY_W):
		direction.z -= 1
	if not blocked and Input.is_physical_key_pressed(KEY_S):
		direction.z += 1
	if not blocked and Input.is_physical_key_pressed(KEY_A):
		direction.x -= 1
	if not blocked and Input.is_physical_key_pressed(KEY_D):
		direction.x += 1
	direction = (transform.basis*direction).normalized()
	var sprint: bool = not blocked and Input.is_physical_key_pressed(KEY_SHIFT) and Input.is_physical_key_pressed(KEY_W) and not crouch
	swimming = global_position.y < -0.7
	var speed: float = 2.2 if swimming else 1.8 if crouch else 5.5 if sprint else 3.5
	velocity.x = move_toward(velocity.x,direction.x*speed,dt*25)
	velocity.z = move_toward(velocity.z,direction.z*speed,dt*25)
	var grounded_before: bool = is_on_floor()
	if swimming:
		velocity.y = move_toward(velocity.y,2.4 if not blocked and Input.is_physical_key_pressed(KEY_SPACE) else 0.7 if position.y < -1.3 else -0.2,dt*4)
	elif is_on_floor():
		velocity.y = 6 if Input.is_physical_key_pressed(KEY_SPACE) else -2
	else:
		velocity.y -= 18*dt
	var impact_speed: float = velocity.y
	move_and_slide()
	if is_on_floor() and not grounded_before and not swimming and impact_speed < -12:
		game.damage((-impact_speed-12)*6)
	position.x = clampf(position.x,-318,318)
	position.z = clampf(position.z,-318,318)
	if position.y < -15:
		game.damage(100)
	if is_on_floor() and direction.length_squared()>0.1:
		bob += dt*speed*2.2
	var eye: float = 1.18 if crouch else 1.65
	head.position.y = lerpf(head.position.y,eye+sin(bob*2)*0.015,dt*12)
	head.rotation.x = pitch
	camera.fov = lerpf(camera.fov,82.0 if sprint else 78.0,dt*5)
	cooldown = maxf(0,cooldown-dt)
	var from: Vector3 = camera.global_position
	var query := PhysicsRayQueryParameters3D.create(from,from-camera.global_basis.z*4.5,1)
	hit = get_world_3d().direct_space_state.intersect_ray(query)
	if not blocked and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and cooldown<=0:
		cooldown = 0.65
		game.primary_action()
	game.prompt = "" if blocked else interaction_prompt()

func interaction_prompt() -> String:
	if not hit.is_empty():
		var body: Object = hit.collider
		if body.has_meta("resource"):
			var kind: String = game.world.nodes[str(body.get_meta("resource"))].kind
			return "E  HARVEST HEMP" if kind=="cloth" else "E  PICK BERRIES" if kind=="berries" else "STRIKE TO GATHER  /  "+("WOOD" if kind=="tree" else kind.to_upper())
		if body.has_meta("corpse"):
			return "E  RECOVER YOUR BELONGINGS"
	if game.world.math.freshwater(position.x,position.z) and position.y<2:
		return "E  DRINK FRESH WATER"
	return ""

func update_model(dt: float) -> void:
	var item: String = game.active_id()
	if item!=current_item:
		current_item = item
		for child in model.get_children():
			model.remove_child(child)
			child.queue_free()
		var art = game.world.art
		var stone: Material = art.material("stone",Color("#929990"))
		var wood: Material = art.material("wood",Color("#8a6e4d"))
		if item=="rock":
			art.rock(model,Vector3.ZERO,Vector3(0.14,0.11,0.17),stone,2)
		elif item in ["axe","pickaxe"]:
			var handle: MeshInstance3D = art.cylinder(model,Vector3(0,-0.08,0),0.018,0.42,wood,0.012)
			handle.rotation.z = -0.2
			art.rock(model,Vector3(-0.01,0.12,0),Vector3(0.12,0.075,0.04) if item=="axe" else Vector3(0.18,0.035,0.04),stone)
		elif item=="torch":
			art.cylinder(model,Vector3.ZERO,0.025,0.4,wood,0.02)
			art.rock(model,Vector3(0,0.21,0),Vector3(0.04,0.07,0.04),art.material("torch_top",Color("#e9ac54")))
	torch_light.visible = item=="torch" and game.playing
	swing = move_toward(swing,0,dt*3.2)
	model.rotation = Vector3(sin(swing*PI)*-0.9,0,sin(swing*PI)*0.4)
	model.position = Vector3(0.28+sin(bob)*0.008,-0.28+sin(bob*2)*0.006,-0.48)
