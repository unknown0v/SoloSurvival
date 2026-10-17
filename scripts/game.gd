extends Node3D
const items = preload("res://scripts/core/items.gd")
const Inventory = preload("res://scripts/core/inventory.gd")
const Crafting = preload("res://scripts/core/crafting.gd")
const SaveStore = preload("res://scripts/core/save_store.gd")
const World = preload("res://scripts/world/island.gd")
const Player = preload("res://scripts/player.gd")
const Hud = preload("res://scripts/ui/hud.gd")
const Settlement = preload("res://scripts/core/settlement.gd")
const Buildings = preload("res://scripts/world/buildings.gd")
const Sound = preload("res://scripts/world/sound.gd")
var settlement = Settlement.new()
var buildings
var build_mode: bool = false
var station_id: String = ""
var bag = Inventory.new(36)
var crafts = Crafting.new()
var saves = SaveStore.new()
var world
var player
var hud
var sound
var stats: Dictionary = {"health":100.0,"hunger":90.0,"thirst":90.0}
var resource_data: Dictionary = {}
var corpses: Array = []
var hour: float = 8.0
var elapsed: float = 0.0
var selected: int = 0
var inspected_slot: int = 0
var playing: bool = false
var paused: bool = false
var menu_open: bool = false
var ready_to_play: bool = false
var prompt: String = ""
var sun: DirectionalLight3D
var environment: Environment
var save_timer: float = 0
var world_timer: float = 0
var web_timer: float = 0
var save_count: int = 0
var corpse_serial: int = 0
var import_callback
signal world_ready

func _ready() -> void:
	get_tree().auto_accept_quit = false
	var saved: Dictionary = saves.load_world()
	if not saved.is_empty():
		bag.slots = saved.inventory.duplicate(true)
		crafts.jobs = saved.jobs.duplicate(true)
		stats = saved.stats.duplicate(true)
		resource_data = saved.resources.duplicate(true)
		corpses = saved.corpses.duplicate(true)
		settlement.pieces = saved.get("structures",[]).duplicate(true)
		hour = float(saved.hour)
		elapsed = float(saved.elapsed)
		selected = int(saved.selected)
	else:
		bag.add("rock",1)
		bag.add("torch",1)
		bag.add("berries",4)
		bag.add("water",2)
		bag.add("bandage",1)
	setup_environment()
	world = World.new()
	add_child(world)
	await world.build(self)
	player = Player.new()
	add_child(player)
	var spawn: Vector3 = Vector3(-150,world.math.height(-150,-155)+0.5,-155)
	var p: Vector3 = spawn
	if not saved.is_empty():
		p = Vector3(saved.position[0],saved.position[1],saved.position[2])
	player.setup(self,p,float(saved.get("yaw",0)),float(saved.get("pitch",0)))
	buildings = Buildings.new()
	add_child(buildings)
	buildings.setup(self)
	hud = Hud.new()
	add_child(hud)
	hud.setup(self)
	sound = Sound.new()
	add_child(sound)
	sound.setup()
	ready_to_play = true
	if not saves.writable:
		hud.warning.text = saves.message
	elif OS.has_feature("web") and not OS.is_userfs_persistent():
		hud.warning.text = "Browser storage may be temporary. Download a save backup before leaving."
	say(saves.message if saves.message!="" else "You washed ashore. Your rock is in slot 1.")
	world_ready.emit()
	print("SOLOSURVIVAL_READY nodes=%d" % world.nodes.size())

func setup_environment() -> void:
	var world_environment := WorldEnvironment.new()
	environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var material := ProceduralSkyMaterial.new()
	material.sky_top_color = Color("#48769a")
	material.sky_horizon_color = Color("#a6b8b9")
	material.ground_bottom_color = Color("#343e39")
	material.ground_horizon_color = Color("#a6b8b9")
	material.sun_angle_max = 5
	sky.sky_material = material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#a4b6b8")
	environment.ambient_light_energy = 0.45
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color("#9aafb0")
	environment.fog_density = 0.0015
	world_environment.environment = environment
	add_child(world_environment)
	sun = DirectionalLight3D.new()
	sun.shadow_enabled = not OS.has_feature("web")
	sun.directional_shadow_max_distance = 95
	sun.light_color = Color("#ffe6bd")
	sun.light_energy = 1.2
	add_child(sun)
	update_light()

func update_light() -> void:
	sun.rotation_degrees = Vector3(hour/24.0*360.0+90.0,-30,0)
	var daylight: float = clampf(sin((hour-6.0)/12.0*PI)*1.2,0,1)
	sun.light_energy = lerpf(0.015,1.15,daylight)
	sun.light_color = Color("#e2a877").lerp(Color("#fff1d2"),daylight)
	environment.ambient_light_energy = lerpf(0.13,0.48,daylight)
	environment.background_energy_multiplier = lerpf(0.09,1.0,daylight)
	environment.fog_light_color = Color("#202c3e").lerp(Color("#9aafb0"),daylight)

func _process(dt: float) -> void:
	if not ready_to_play:
		return
	if playing and not paused and float(stats.health)>0:
		dt = minf(dt,0.1)
		elapsed += dt
		settlement.tick(dt)
		hour = fmod(hour+dt*24.0/1800.0,24)
		update_light()
		tick_survival(dt,Vector2(player.velocity.x,player.velocity.z).length()>4.5,player.camera.global_position.y < -0.25)
		var output: String = crafts.tick(dt,bag)
		if output!="":
			say("Crafted "+str(items.ITEMS[output].name))
		world_timer += dt
		if world_timer>=1:
			world_timer = 0
			world.tick()
		save_timer += dt
		if save_timer>=30:
			save_timer = 0
			save_world(false)
	web_timer += dt
	if OS.has_feature("web") and web_timer>=0.25:
		web_timer = 0
		# Read-only diagnostics used by cloud browser smoke tests.
		var report: Dictionary = {"ui":hud.diagnostics(),"structures":settlement.pieces.size(),"building":build_mode,"build_kind":buildings.build_kind,"placement":buildings.placement_reason,"station":station_id,"structure_data":settlement.pieces,"inventory":bag.slots,"crafts":crafts.jobs,"ready":true,"playing":playing,"paused":paused,"menu":menu_open,"mouse":Input.mouse_mode,"hit":str(player.hit.get("collider","")),"prompt":prompt,"fps":Engine.get_frames_per_second(),"yaw":player.rotation.y,"pitch":player.pitch,"position":[player.position.x,player.position.y,player.position.z],"ground":world.math.height(player.position.x,player.position.z),"nodes":world.nodes.size(),"wood":bag.count_item("wood"),"saves":save_count,"health":stats.health,"hour":hour}
		JavaScriptBridge.eval("window.__soloSurvivalState="+JSON.stringify(report),true)

func _unhandled_input(event: InputEvent) -> void:
	if not ready_to_play or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode==KEY_ENTER and (not playing or paused):
		start_playing()
	elif event.physical_keycode==KEY_ESCAPE:
		if menu_open:
			toggle_inventory()
		elif playing:
			paused = not paused
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
			if paused:
				save_world(false)
	elif event.physical_keycode==KEY_B and playing and not paused and not menu_open:
		if bag.count_item("building_plan")>0:
			build_mode = not build_mode
			say("Building plan: 1–9 select, R rotate, left click place." if build_mode else "Building plan put away.")
		else:
			say("Craft a building plan in your inventory first.")
	elif event.physical_keycode==KEY_R and build_mode and not menu_open:
		buildings.edge = (buildings.edge+1)%4
		buildings.timer = 0
	elif event.physical_keycode in [KEY_U,KEY_X] and playing and not paused and not menu_open and not build_mode:
		hammer_action(event.physical_keycode==KEY_U)
	elif event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9 and build_mode and not menu_open:
		buildings.build_kind = Settlement.KINDS[event.physical_keycode-KEY_1]
		buildings.timer = 0
	elif event.physical_keycode==KEY_TAB and playing and not paused:
		toggle_inventory()
	elif event.physical_keycode==KEY_F5:
		save_world()
	elif event.physical_keycode==KEY_E and playing and not menu_open and not paused:
		interact()
	elif event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_6 and not menu_open:
		select_slot(event.physical_keycode-KEY_1)

func start_playing() -> void:
	if not ready_to_play or float(stats.health)<=0:
		return
	playing = true
	paused = false
	menu_open = false
	station_id = ""
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle_inventory() -> void:
	if float(stats.health)<=0:
		return
	station_id = ""
	menu_open = not menu_open
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if menu_open else Input.MOUSE_MODE_CAPTURED

func active_id() -> String:
	return str(bag.slots[selected].get("id",""))

func select_slot(index: int) -> void:
	selected = clampi(index,0,5)
	inspected_slot = selected
	if hud!=null:
		hud.refresh()

func primary_action() -> void:
	if float(stats.health)<=0:
		return
	if build_mode:
		buildings.place()
		return
	var id: String = active_id()
	if id=="hammer":
		hammer_action(false,true)
		return
	if id in ["berries","cooked_berries","water","bandage"]:
		use_item(selected)
		return
	if id not in ["rock","axe","pickaxe"]:
		return
	var item: Dictionary = bag.slots[selected]
	if int(item.condition)<=0:
		say("Your tool is broken. Craft another or recover a rock after respawning.")
		return
	if not player.hit.is_empty() and player.hit.collider.has_meta("structure"):
		if settlement.strike(str(player.hit.collider.get_meta("structure")),12):
			wear_tool()
		else:
			say("Empty all affected containers before destruction.")
		return
	player.swing = 1
	sound.hit(false)
	if not player.hit.is_empty() and player.hit.collider.has_meta("resource"):
		world.harvest(str(player.hit.collider.get_meta("resource")),id)

func interact() -> void:
	if float(stats.health)<=0:
		return
	if not player.hit.is_empty():
		var body: Object = player.hit.collider
		if body.has_meta("structure"):
			var id: String = str(body.get_meta("structure"))
			var p: Dictionary = settlement.find(id)
			if p.kind=="door":
				buildings.toggle_door(id)
			elif Settlement.station(p.kind):
				open_station(id)
			return
		if body.has_meta("resource"):
			var id: String = str(body.get_meta("resource"))
			if world.nodes[id].kind in ["cloth","berries"]:
				world.harvest(id,"hand")
				return
		if body.has_meta("corpse"):
			recover_corpse(str(body.get_meta("corpse")))
			return
	if world.math.freshwater(player.position.x,player.position.z) and player.position.y<2:
		stats.thirst = minf(100,float(stats.thirst)+35)
		say("Fresh river water · thirst restored")

func wear_tool() -> void:
	if bag.slots[selected].is_empty():
		return
	var stack: Dictionary = bag.slots[selected]
	if int(items.ITEMS[stack.id].durability)>0:
		stack.condition = maxi(0,int(stack.condition)-1)
		bag.changed.emit()

func use_item(index: int) -> void:
	if float(stats.health)<=0:
		return
	if index<0 or index>=bag.slots.size() or bag.slots[index].is_empty():
		return
	var item: Dictionary = bag.slots[index]
	var id: String = item.id
	if id=="cooked_berries":
		stats.hunger = minf(100,float(stats.hunger)+32)
		stats.health = minf(100,float(stats.health)+4)
	elif id=="berries":
		stats.hunger = minf(100,float(stats.hunger)+12)
		stats.thirst = minf(100,float(stats.thirst)+6)
	elif id=="water":
		stats.thirst = minf(100,float(stats.thirst)+40)
	elif id=="bandage":
		stats.health = minf(100,float(stats.health)+20)
	else:
		say(str(items.ITEMS[id].description))
		return
	item.count -= 1
	if int(item.count)==0:
		bag.slots[index] = {}
	bag.changed.emit()
	say("Used "+str(items.ITEMS[id].name))

func queue_craft(id: String) -> void:
	if float(stats.health)<=0:
		return
	if crafts.enqueue(id,bag):
		say("Queued "+str(items.ITEMS[id].name))
	else:
		say("Missing resources or queue full.")
	hud.refresh()

func tick_survival(dt: float, exertion: bool, submerged: bool) -> void:
	stats.hunger = maxf(0,float(stats.hunger)-dt*(0.05 if exertion else 0.025))
	stats.thirst = maxf(0,float(stats.thirst)-dt*(0.08 if exertion else 0.04))
	var rate: float = (0.7 if stats.hunger<=0 else 0.0)+(1.2 if stats.thirst<=0 else 0.0)+(6.0 if submerged else 0.0)
	if rate>0:
		damage(rate*dt)
	elif float(stats.hunger)>60 and float(stats.thirst)>50:
		stats.health = minf(100,float(stats.health)+dt*0.08)

func damage(amount: float) -> void:
	if float(stats.health)<=0:
		return
	stats.health = maxf(0,float(stats.health)-amount)
	if float(stats.health)<=0:
		die()

func die() -> void:
	corpses = corpses.filter(func(c): return c.inventory.any(func(s): return not s.is_empty()))
	if corpses.size()<32:
		corpse_serial += 1
		var p: Vector3 = player.position
		corpses.append({"id":str(Time.get_unix_time_from_system())+"-"+str(corpse_serial),"position":[p.x,maxf(p.y,world.math.height(p.x,p.z)),p.z],"inventory":bag.slots.duplicate(true)})
		bag.slots = Inventory.new(36).slots
		bag.changed.emit()
		world.update_corpse()
	else:
		say("Death-container limit reached. Your carried items are retained.")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	menu_open = false
	station_id = ""
	build_mode = false
	save_world(false)

func respawn() -> void:
	stats = {"health":100.0,"hunger":70.0,"thirst":70.0}
	selected = 0
	inspected_slot = 0
	if bag.count_item("rock")==0:
		bag.add("rock",1)
	if bag.count_item("torch")==0:
		bag.add("torch",1)
	player.position = Vector3(-150,world.math.height(-150,-155)+0.5,-155)
	player.velocity = Vector3.ZERO
	start_playing()
	say("Your belongings remain where you fell.")
	save_world(false)

func recover_corpse(id: String) -> void:
	for c in corpses:
		if c.id!=id:
			continue
		for i in range(c.inventory.size()):
			var item: Dictionary = c.inventory[i]
			if item.is_empty():
				continue
			item.count = bag.add(item.id,int(item.count),int(item.condition))
			if int(item.count)==0:
				c.inventory[i] = {}
		say("Recovered what fits in your inventory.")
		if not c.inventory.any(func(s): return not s.is_empty()):
			corpses.erase(c)
			world.update_corpse()
		save_world(false)
		return

func capture() -> Dictionary:
	var p: Vector3 = player.position
	return {"version":2,"structures":settlement.pieces.duplicate(true),"seed":197403,"position":[p.x,p.y,p.z],"yaw":player.rotation.y,"pitch":player.pitch,"selected":selected,"inventory":bag.slots.duplicate(true),"jobs":crafts.jobs.duplicate(true),"stats":stats.duplicate(true),"hour":hour,"elapsed":elapsed,"resources":resource_data.duplicate(true),"corpses":corpses.duplicate(true)}

func save_world(notify: bool = true) -> void:
	if not ready_to_play:
		return
	if saves.write(capture()):
		save_count += 1
	if notify:
		say(saves.message)

func download_save() -> void:
	if not ready_to_play:
		return
	var text: String = SaveStore.encode_save(capture())
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(text.to_utf8_buffer(),"solosurvival-save.json","application/json")
		say("Save backup downloaded. Keep it somewhere safe.")
	else:
		var path: String = "user://solosurvival-backup.json"
		var file := FileAccess.open(path,FileAccess.WRITE)
		if file!=null:
			file.store_string(text)
			file.close()
			say("Backup written to "+ProjectSettings.globalize_path(path))

func say(text: String) -> void:
	if hud!=null:
		hud.say(text)

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		save_world(false)
		get_tree().quit()
	elif what==NOTIFICATION_APPLICATION_FOCUS_OUT and ready_to_play and playing:
		save_world(false)
		paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func import_backup() -> void:
	if not OS.has_feature("web"):
		say("Native saves load automatically. Backups are in the local save directory.")
		return
	import_callback = JavaScriptBridge.create_callback(finish_import)
	var window = JavaScriptBridge.get_interface("window")
	window.__soloSurvivalImport = import_callback
	JavaScriptBridge.eval("(function(){const input=document.createElement('input');input.type='file';input.accept='.json,application/json';input.onchange=async()=>{try{const f=input.files[0];if(!f||f.size>2097152){window.__soloSurvivalImport('');return;}window.__soloSurvivalImport(await f.text());}catch(e){window.__soloSurvivalImport('');}};input.click();})()",true)

func finish_import(arguments: Array) -> void:
	if arguments.is_empty() or not arguments[0] is String or arguments[0]=="":
		say("No valid backup selected.")
		return
	var result: Dictionary = SaveStore.unwrap(arguments[0])
	if result.has("error"):
		say("Backup rejected: "+str(result.error))
		return
	var suffix: String = ".before-import-"+str(Time.get_unix_time_from_system()).replace(".","-")
	for path in [saves.path,saves.path+".bak"]:
		if FileAccess.file_exists(path) and DirAccess.copy_absolute(path,path+suffix)!=OK:
			say("Could not preserve existing saves. Import cancelled.")
			return
	saves.writable = true
	if not saves.write(result.data):
		say(saves.message)
		return
	ready_to_play = false
	get_tree().call_deferred("reload_current_scene")

func hammer_action(upgrading: bool, repairing: bool = false) -> void:
	if active_id()!="hammer" or int(bag.slots[selected].condition)<=0:
		say("Select a working building hammer.")
		return
	if player.hit.is_empty() or not player.hit.collider.has_meta("structure"):
		return
	var id: String = str(player.hit.collider.get_meta("structure"))
	var ok: bool = false
	if upgrading:
		ok = settlement.upgrade(id,bag)
	elif repairing:
		ok = settlement.repair(id,bag)
	else:
		ok = settlement.dismantle(id)
	if ok:
		wear_tool()
		save_world(false)
		say("Structure upgraded." if upgrading else "Structure repaired." if repairing else "Structure dismantled; unsupported pieces collapsed. No refund.")
	else:
		say("No change: check materials/tier/health; empty every affected container before dismantling.")

func open_station(id: String) -> void:
	station_id = id
	menu_open = true
	build_mode = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_station(id)

func toggle_station() -> void:
	var p: Dictionary = settlement.find(station_id)
	if p.is_empty() or p.kind=="storage":
		return
	p.active = not p.active
	settlement.changed.emit()
	save_world(false)
	hud.refresh_station()

func station_transfer(from_player: bool) -> void:
	var p: Dictionary = settlement.find(station_id)
	if p.is_empty():
		return
	var target = Inventory.new(12)
	target.slots = p.inventory
	var source = bag if from_player else target
	var destination = target if from_player else bag
	for i in range(source.slots.size()):
		var stack: Dictionary = source.slots[i]
		if stack.is_empty():
			continue
		var remainder: int = destination.add(stack.id,int(stack.count),int(stack.condition))
		stack.count = remainder
		if remainder==0:
			source.slots[i] = {}
	bag.changed.emit()
	save_world(false)
	hud.refresh_station()
