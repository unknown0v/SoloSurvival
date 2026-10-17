extends SceneTree
const Settlement = preload("res://scripts/core/settlement.gd")
const Inventory = preload("res://scripts/core/inventory.gd")
const Crafting = preload("res://scripts/core/crafting.gd")
const Save = preload("res://scripts/core/save_store.gd")
const WorldMath = preload("res://scripts/core/world_math.gd")
const Game = preload("res://scripts/game.gd")
var failures: Array = []
var assertions: int = 0
var finished: bool = false
var watchdog_timer: SceneTreeTimer

func _initialize() -> void:
	call_deferred("run_tests")
	call_deferred("watchdog")

func watchdog() -> void:
	watchdog_timer = create_timer(100)
	await watchdog_timer.timeout
	if not finished:
		printerr("TEST TIMEOUT")
		quit(1)

func check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		failures.append(description)
		printerr("FAIL: "+description)

func fixture() -> Dictionary:
	var bag = Inventory.new(36)
	bag.add("rock",1)
	return {"version":1,"seed":197403,"position":[-150.0,12.0,-155.0],"yaw":0.0,"pitch":0.0,"selected":0,"inventory":bag.slots,"jobs":[],"stats":{"health":100.0,"hunger":90.0,"thirst":90.0},"hour":8.0,"elapsed":0.0,"resources":{},"corpses":[]}

func write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(text)
	file.close()

func domain_tests() -> void:
	var bag = Inventory.new(2)
	check(bag.add("wood",2100)==100,"Insertion returns overflow")
	check(bag.count_item("wood")==2000,"Stack limits respected")
	check(not bag.remove("wood",2001),"Removal is atomic when short")
	check(bag.count_item("wood")==2000,"Failed removal preserves contents")
	bag.slots = [{"id":"wood","count":9,"condition":0},{}]
	check(bag.split(0),"Split succeeds")
	check(bag.slots[0].count==4 and bag.slots[1].count==5,"Odd split conserves total")
	bag.transfer(0,bag,1)
	check(bag.slots[0].is_empty() and bag.slots[1].count==9,"Merge conserves items")
	bag.slots[0] = {"id":"stone","count":7,"condition":0}
	bag.transfer(0,bag,1)
	check(bag.slots[0].id=="wood" and bag.slots[1].id=="stone","Incompatible items swap")
	bag.transfer(0,bag,0)
	check(bag.count_item("wood")==9,"Self transfer is a no-op")
	check(Inventory.valid(bag.slots,2),"Generated slots validate")
	var corrupt: Array = bag.slots.duplicate(true)
	corrupt[0].count = -1
	check(not Inventory.valid(corrupt,2),"Negative count rejected")
	corrupt = bag.slots.duplicate(true)
	corrupt[0].id = "unknown"
	check(not Inventory.valid(corrupt,2),"Unknown item rejected")
	var queue = Crafting.new()
	bag = Inventory.new(4)
	bag.add("wood",120)
	bag.add("stone",60)
	check(queue.enqueue("axe",bag),"Craft reserves ingredients")
	check(bag.count_item("wood")==0 and bag.count_item("stone")==0,"Ingredients charged exactly once")
	check(queue.tick(3,bag)=="","Craft waits for elapsed time")
	check(queue.tick(2,bag)=="axe" and bag.count_item("axe")==1,"Completed craft delivered")
	check(queue.tick(100,bag)=="" and bag.count_item("axe")==1,"Completed craft cannot duplicate")
	bag = Inventory.new(1)
	bag.add("wood",1000)
	queue.jobs = [{"id":"axe","remaining":0.0}]
	check(queue.tick(1,bag)=="" and queue.jobs.size()==1,"Full inventory retains completed job")
	check(not queue.cancel(0,bag),"Refund requiring room is atomic")
	check(bag.count_item("wood")==1000 and queue.jobs.size()==1,"Rejected refund preserves items and queue")
	bag.remove("wood",1000)
	check(queue.tick(1,bag)=="axe","Pending output delivered when room exists")
	var math = WorldMath.new()
	check(math.height(-150,-155)>1,"Starting shore is above water")
	check(math.height(319,319)<0,"Island edges are underwater")
	check(is_equal_approx(math.height(20,30),WorldMath.new().height(20,30)),"World is deterministic")
	check(is_equal_approx(math.height(20,32),math.raw_height(20,32)),"Original terrain vertices and seed preserved")
	var expected: float = math.raw_height(20,32)*0.5+math.raw_height(24,32)*0.25+math.raw_height(20,36)*0.25
	check(is_equal_approx(math.height(21,33),expected),"Surface query follows actual collision triangle")

func construction_tests() -> void:
	var model = Settlement.new()
	var bag = Inventory.new(36)
	bag.add("wood",5000)
	bag.add("stone",3000)
	bag.add("metal",1000)
	var unsupported: Dictionary = model.make_piece("wall",[0,0],10,0,0)
	check(model.place(unsupported,bag).is_empty(),"Unsupported walls cannot be built")
	var before: int = bag.count_item("wood")
	var foundation: Dictionary = model.place(model.make_piece("foundation",[0,0],10,0,0),bag)
	check(not foundation.is_empty() and bag.count_item("wood")==before-30,"Foundation atomically charges resources")
	check(model.place(model.make_piece("foundation",[0,0],10,0,0),bag).is_empty(),"Duplicate socket rejected")
	var wall: Dictionary = model.place(unsupported,bag)
	check(not wall.is_empty(),"Wall snaps to foundation")
	var frame: Dictionary = model.place(model.make_piece("doorframe",[0,0],10,0,1),bag)
	var door: Dictionary = model.place(model.make_piece("door",[0,0],10,0,1),bag)
	check(not frame.is_empty() and not door.is_empty(),"Door fits supported frame")
	check(model.place(model.make_piece("door",[0,0],10,0,2),bag).is_empty(),"Door without frame rejected")
	var floor_piece: Dictionary = model.place(model.make_piece("floor",[0,0],10,1,0),bag)
	check(not floor_piece.is_empty(),"Upper floor derives support from walls")
	var overhang: Dictionary = model.place(model.make_piece("floor",[1,0],10,1,0),bag)
	check(not overhang.is_empty(),"One adjacent floor cantilevers with reduced integrity")
	check(model.place(model.make_piece("floor",[2,0],10,1,0),bag).is_empty(),"Excessive cantilever rejected")
	var upper: Dictionary = model.place(model.make_piece("wall",[0,0],10,1,0),bag)
	var roof: Dictionary = model.place(model.make_piece("roof",[0,0],10,2,0),bag)
	check(not upper.is_empty() and not roof.is_empty(),"Upper wall and roof retain a support path")
	check(model.upgrade(wall.id,bag) and wall.tier==1 and wall.hp==250,"Wood upgrade applies health and cost")
	check(model.upgrade(wall.id,bag) and wall.tier==2,"Stone upgrade succeeds")
	check(model.upgrade(wall.id,bag) and wall.tier==3,"Metal upgrade succeeds")
	check(not model.upgrade(wall.id,bag),"Maximum upgrade cannot charge again")
	check(model.strike(wall.id,30) and wall.hp==970,"Construction damage reduces health")
	check(model.repair(wall.id,bag) and wall.hp==1000,"Repair consumes material and restores health")
	var storage: Dictionary = model.place(model.make_piece("storage",[0,0],10,0,0),bag)
	var box = Inventory.new(12)
	box.slots = storage.inventory
	box.add("ore",20)
	check(not model.dismantle(foundation.id) and model.find(storage.id).inventory==box.slots,"Collapse cannot discard stored contents")
	var restored = Settlement.new()
	restored.pieces = JSON.parse_string(JSON.stringify(model.pieces))
	check(Settlement.valid(restored.pieces),"Structure graph and stored items survive JSON roundtrip")
	check(restored.reason(restored.make_piece("wall",[0,0],10,0,0))=="That socket is occupied.","Loaded numeric cell identities match newly snapped sockets")
	var bad: Array = restored.pieces.duplicate(true)
	bad[0].hp = -2
	check(not Settlement.valid(bad),"Malformed structure health rejected")
	bad = restored.pieces.duplicate(true)
	bad.append(bad[0].duplicate(true))
	check(not Settlement.valid(bad),"Duplicate construction identity rejected")
	box.remove("ore",20)
	check(model.dismantle(frame.id) and model.find(door.id).is_empty(),"Removing a frame collapses its door")
	check(model.dismantle(foundation.id) and model.pieces.is_empty(),"Removing the root collapses unsupported graph")
	var fire: Dictionary
	var furnace: Dictionary
	model.place(model.make_piece("foundation",[0,0],10,0,0),bag)
	fire = model.place(model.make_piece("campfire",[0,0],10,0,0),bag)
	furnace = model.place(model.make_piece("furnace",[0,0],10,0,0),bag)
	var inputs = Inventory.new(12)
	inputs.slots = fire.inventory
	inputs.add("berries",4)
	inputs.add("wood",4)
	fire.active = true
	model.tick(4)
	check(inputs.count_item("cooked_berries")==0 and fire.progress==4,"Cooking waits for simulated time")
	model.tick(1)
	check(inputs.count_item("cooked_berries")==1 and inputs.count_item("berries")==2 and inputs.count_item("wood")==3,"Cooking consumes exactly one recipe batch")
	var ore_bag = Inventory.new(12)
	ore_bag.slots = furnace.inventory
	ore_bag.add("ore",4)
	ore_bag.add("wood",2)
	furnace.active = true
	model.tick(8)
	check(ore_bag.count_item("metal")==1 and ore_bag.count_item("ore")==2,"Furnace smelts ore with wood fuel")
	furnace.active = false
	model.tick(8)
	check(ore_bag.count_item("metal")==1,"Stopped furnace does not process")
	ore_bag.slots = Inventory.new(12).slots
	furnace.inventory = ore_bag.slots
	ore_bag.add("ore",1000)
	ore_bag.add("wood",1000)
	for i in range(10):
		ore_bag.add("stone",1000)
	furnace.active = true
	model.tick(8)
	check(ore_bag.count_item("ore")==1000 and ore_bag.count_item("wood")==1000,"Full output inventory preserves ingredients and fuel")
	var world: Dictionary = fixture()
	check(Save.unwrap(Save.encode_save(world)).has("data"),"Unmodified milestone-one save still loads")
	world.version = 2
	world.structures = model.pieces.duplicate(true)
	check(Save.validate(world)=="","Version-two save validates stations and structures")
	world.structures = [{"kind":"unknown"}]
	check(Save.validate(world)!="","Invalid version-two extension rejected")

func base_progression_tests() -> void:
	var model = Settlement.new()
	var bag = Inventory.new(36)
	bag.add("wood",3000)
	bag.add("stone",1000)
	bag.add("metal",300)
	bag.add("cloth",100)
	var foundation: Dictionary = model.place(model.make_piece("foundation",[0,0],10,0,0),bag)
	var box: Dictionary = model.place(model.make_piece("cupboard",[0,0],10,0,0),bag)
	check(not box.is_empty() and box.inventory.size()==12,"Cupboard has persistent upkeep inventory")
	var resources = Inventory.new(12)
	resources.slots = box.inventory
	resources.add("wood",10)
	model.upkeep_grace = 0
	model.tick(300)
	check(foundation.hp==80 and resources.count_item("wood")==9,"Paid upkeep consumes exact material and prevents decay")
	resources.remove("wood",9)
	model.tick(300)
	check(foundation.hp==72,"Unpaid upkeep damages the building")
	check(not model.strike(foundation.id,-20) and foundation.hp==72,"Negative damage cannot create health")
	model.place(model.make_piece("foundation",[1,0],10,0,0),bag)
	var home: Dictionary = model.place(model.make_piece("sleeping_bag",[1,0],10,0,0),bag)
	check(not home.is_empty() and model.bind_bag(home.id),"Sleeping bag can bind respawn")
	check(model.respawn_piece().id==home.id,"Bound bag is selected by the owner")
	var bench: Dictionary = model.place(model.make_piece("workbench",[0,0],10,0,0),bag)
	check(not bench.is_empty(),"Workbench charges construction resources")
	var crafting = Crafting.new()
	var before: int = bag.count_item("metal")
	check(not crafting.enqueue("metal_pickaxe",bag),"Advanced tool recipe requires a workbench")
	check(bag.count_item("metal")==before,"Failed workbench requirement cannot reserve ingredients")
	check(crafting.enqueue("metal_pickaxe",bag,1),"Workbench unlocks the metal tool recipe")
	check(crafting.tick(8,bag)=="metal_pickaxe","Workbench tool completes with durability")
	check(Settlement.valid(JSON.parse_string(JSON.stringify(model.pieces))),"Bag binding and cupboard survive JSON validation")
	var legacy: Dictionary = fixture()
	legacy.structures = "uninterpreted version-one extension"
	legacy.maintenance = "uninterpreted version-one extension"
	check(Save.settlement_state(legacy).pieces.is_empty() and Save.settlement_state(legacy).grace==1800,"Old schemas do not reinterpret newer extension fields")
	var data: Dictionary = fixture()
	data.version = 3
	data.structures = model.pieces.duplicate(true)
	data.maintenance = {"grace":model.upkeep_grace,"clock":model.upkeep_clock}
	check(Save.unwrap(Save.encode_save(data)).has("data"),"Schema three preserves upkeep, bag and workbench")
	data.maintenance.clock = -1
	check(Save.validate(data)!="","Invalid upkeep clock is rejected")
	# Material-specific protection and independent-base separation.
	resources.add("wood",10)
	model.upgrade(foundation.id,bag)
	model.upgrade(foundation.id,bag)
	var before_hp: float = foundation.hp
	model.tick(300)
	check(foundation.hp<before_hp,"Wood stock cannot protect stone construction")
	check(model.find(home.id).respawn,"Upkeep retains a surviving bound bag")
	var distant: Dictionary = model.place(model.make_piece("foundation",[10,10],10,0,0),bag)
	resources.add("stone",10)
	var notifications: Array = [0]
	model.changed.connect(func(): notifications[0] += 1)
	model.tick(300)
	check(notifications[0]==1,"Upkeep coalesces component mutations into one notification")
	check(distant.hp<80,"Disconnected base is not protected by another cupboard")

func browser_fixture(game) -> void:
	# Import a real version-one save through the browser file chooser, not a game command bridge.
	var math = game.world.math
	for z in range(-75,60):
		for x in range(-75,60):
			var wx: float = x*3.0
			var wz: float = z*3.0
			var h: float = math.height(wx,wz)
			var y: float = snappedf(h+0.4,0.25)
			if h<3 or h>45:
				continue
			var clear: bool = true
			for dx in [-1.4,0,1.4]:
				for dz in [-1.4,0,1.4]:
					var sample: float = math.height(wx+dx,wz+dz)
					if sample>y or y-sample>0.75:
						clear = false
			for resource in game.world.nodes.values():
				if Vector2(resource.body.position.x-wx,resource.body.position.z-wz).length()<8:
					clear = false
			if not clear:
				continue
			var data: Dictionary = fixture()
			var inv = Inventory.new(36)
			inv.add("rock",1)
			inv.add("wood",1000)
			inv.add("stone",1000)
			inv.add("ore",40)
			inv.add("berries",20)
			for index in range(1,5):
				inv.slots[index+5] = inv.slots[index]
				inv.slots[index] = {}
			data.inventory = inv.slots
			data.position = [wx,math.height(wx,wz+4.3)+0.05,wz+4.3]
			data.pitch = -atan2(float(data.position[1])+1.65-h,4.3)
			data.hour = 12
			DirAccess.make_dir_recursive_absolute("res://build")
			write_text("res://build/.gdignore","")
			write_text("res://build/milestone1-fixture.json",Save.encode_save(data))
			var advanced: Dictionary = data.duplicate(true)
			var supplies = Inventory.new(36)
			for id in ["rock","building_plan","hammer"]:
				supplies.add(id,1)
			supplies.add("wood",1000)
			supplies.add("stone",1000)
			supplies.add("metal",200)
			supplies.add("cloth",90)
			advanced.inventory = supplies.slots
			advanced.version = 2
			advanced.structures = []
			write_text("res://build/progression-fixture.json",Save.encode_save(advanced))
			print("CONSTRUCTION_BROWSER_FIXTURE cell="+str([x,z])+" y="+str(y))
			return
	check(false,"Find dry unobstructed terrain for browser construction fixture")

func save_tests() -> void:
	var path: String = "user://cloud-tests-"+str(Time.get_ticks_usec())+".json"
	var store = Save.new(path)
	check(store.load_world().is_empty() and store.writable,"New world can save")
	var original: Dictionary = fixture()
	check(Save.validate(original)=="","Fixture is valid")
	check(store.write(original),"Initial save commits")
	var updated: Dictionary = original.duplicate(true)
	updated.hour = 12
	check(store.write(updated),"Second save preserves backup")
	var loaded = Save.new(path)
	check(loaded.load_world().hour==12,"Current generation loads")
	write_text(path,"corrupt")
	var recovered = Save.new(path)
	var data: Dictionary = recovered.load_world()
	check(not data.is_empty() and data.hour==8,"Corruption recovers previous generation")
	check(recovered.writable,"Recovered save can advance")
	check(recovered.write(updated),"Recovered world saves successfully")
	var future: Dictionary = updated.duplicate(true)
	future.version = 999
	write_text(path,Save.encode_save(future))
	var unsupported = Save.new(path)
	check(unsupported.load_world().is_empty() and not unsupported.writable,"Future version blocks writes without rollback")
	check(FileAccess.get_file_as_string(path)==Save.encode_save(future),"Future save remains byte-for-byte intact")
	var malformed: Dictionary = original.duplicate(true)
	malformed.stats.health = -1
	check(Save.validate(malformed)!="","Invalid survival stats rejected")
	var envelope: Dictionary = JSON.parse_string(Save.encode_save(original))
	envelope.sha256 = "mismatch"
	check(Save.unwrap(JSON.stringify(envelope)).has("error"),"Digest mismatch rejected")
	for filename in DirAccess.get_files_at("user://"):
		if filename.begins_with(path.get_file()):
			DirAccess.remove_absolute("user://"+filename)

func construction_scene_tests(game) -> void:
	var data: Dictionary = Save.unwrap(FileAccess.get_file_as_string("res://build/milestone1-fixture.json")).data
	var pos: Array = data.position
	game.player.position = Vector3(pos[0],pos[1],pos[2])
	game.player.rotation.y = 0
	game.player.pitch = float(data.pitch)
	game.bag.add("wood",1000)
	game.bag.add("stone",1000)
	for i in range(4):
		await physics_frame
	game.buildings.build_kind = "foundation"
	game.buildings.edge = 0
	game.buildings.update_candidate()
	var camera: Camera3D = game.player.camera
	var ray := PhysicsRayQueryParameters3D.create(camera.global_position,camera.global_position-camera.global_basis.z*12,1)
	print("CAMERA_DIAGNOSTIC from="+str(camera.global_position)+" direction="+str(-camera.global_basis.z)+" long_hit="+str(game.get_world_3d().direct_space_state.intersect_ray(ray)))
	print("PLACEMENT_DIAGNOSTIC candidate="+str(game.buildings.candidate)+" reason="+game.buildings.placement_reason+" player="+str(game.player.position)+" pitch="+str(game.player.pitch))
	check(game.buildings.placement_reason=="","Real terrain ray produces valid foundation preview")
	check(game.buildings.place(),"Real-world foundation placement succeeds")
	for i in range(2):
		await physics_frame
	game.buildings.build_kind = "doorframe"
	check(game.buildings.place(),"Frame snaps through production ray placement")
	for i in range(2):
		await physics_frame
	game.buildings.build_kind = "door"
	check(game.buildings.place(),"Door physical clearance accepts its frame")
	for i in range(2):
		await physics_frame
	var doors: Array = game.settlement.pieces.filter(func(p): return p.kind=="door")
	if doors.is_empty():
		return
	var door: Dictionary = doors[0]
	check(game.buildings.toggle_door(door.id) and door.open,"Production door opens through hinge joint")
	for i in range(2):
		await physics_frame
	var at: Vector3 = game.Buildings.origin(door)
	game.player.position = at+Vector3(0,0.05,-1.5)
	for i in range(2):
		await physics_frame
	check(not game.buildings.toggle_door(door.id) and door.open,"Door cannot close through the player")
	game.player.position = Vector3(pos[0],pos[1],pos[2])
	for i in range(2):
		await physics_frame
	check(game.buildings.toggle_door(door.id) and not door.open,"Clear doorway closes")
	var top: Dictionary = game.settlement.make_piece("floor",door.cell,float(door.y),1,0)
	check(game.buildings.check_placement(top)=="","Floor accepts intentional wall/frame support joint")
	var floor_piece: Dictionary = game.settlement.place(top,game.bag)
	check(not floor_piece.is_empty(),"Supported floor instantiates collider")
	for i in range(2):
		await physics_frame
	game.player.position = at+Vector3(0,3.1,0)
	game.player.velocity = Vector3.ZERO
	for i in range(30):
		await physics_frame
	check(absf(game.player.position.y-at.y-3)<0.2,"Player stands on constructed upper floor")
	var storage: Dictionary = game.settlement.make_piece("storage",door.cell,float(door.y),1,0)
	check(game.buildings.check_placement(storage)!="","Placement rejects overlap with the player")
	check(Save.validate(game.capture())=="","Production building world serializes current schema")
	game.bag.add("cloth",100)
	game.bag.add("metal",150)
	game.player.position = at+Vector3(1,3.1,0)
	for i in range(2):
		await physics_frame
	var home: Dictionary = game.settlement.place(game.settlement.make_piece("sleeping_bag",door.cell,float(door.y),1,0),game.bag)
	check(not home.is_empty() and game.settlement.bind_bag(home.id),"Production world binds a supported upper-floor bag")
	game.damage(100)
	for i in range(2):
		await physics_frame
	game.respawn()
	check(game.player.position.distance_to(game.Buildings.origin(home))<1.2,"Death respawns beside the bound bag")
	check(game.player.position.x<at.x,"Respawn chooses a clear side rather than the corpse collision")
	game.recover_corpse(str(game.corpses.back().id))
	var bench: Dictionary = game.settlement.place(game.settlement.make_piece("workbench",door.cell,float(door.y),0,0),game.bag)
	check(not bench.is_empty() and game.workbench_tier()==1,"Nearby production workbench provides a crafting tier")
	check(Save.validate(game.capture())=="","Live world captures bag, bench and upkeep state")

func run_tests() -> void:
	domain_tests()
	construction_tests()
	base_progression_tests()
	save_tests()
	var game = Game.new()
	root.add_child(game)
	await game.world_ready
	browser_fixture(game)
	check(game.world.forest.resource_visible("500"),"Batched starting tree is visible")
	game.world.set_resource_visible("500",false)
	check(not game.world.forest.resource_visible("500"),"Visibility owner records depletion request")
	game.world.set_resource_visible("500",true)
	check(game.world.forest.resource_visible("500"),"Visibility owner records respawn request")
	check(game.world.forest.batches.size()<game.world.nodes.size(),"Forest is bounded into shared draw batches")
	check(game.world.nodes.size()>100,"Real world generates resource nodes")
	game.playing = true
	for i in range(90):
		await physics_frame
	check(game.player.position.y>game.world.math.height(game.player.position.x,game.player.position.z)-0.8,"Player collides with island terrain")
	check(game.player.position.y<game.world.math.height(game.player.position.x,game.player.position.z)+2,"Player settles on ground")
	var before: int = game.bag.count_item("wood")
	game.player.hit = {"collider":game.world.nodes["500"].body}
	game.primary_action()
	check(game.bag.count_item("wood")>before,"Production action harvests wood")
	check(game.bag.slots[0].condition==299,"Harvest consumes tool durability")
	# A real airborne controller must land, lose health, and keep falling with inventory open.
	game.menu_open = true
	game.player.position.y += 16
	game.player.velocity = Vector3.ZERO
	for i in range(150):
		await physics_frame
	check(game.stats.health>0 and game.stats.health<95,"A hard landing applies fall damage")
	check(absf(game.player.position.y-game.world.math.height(game.player.position.x,game.player.position.z))<1,"Inventory does not suspend gravity")
	game.menu_open = false
	var carried: int = game.bag.count_item("wood")
	game.damage(100)
	check(game.stats.health==0 and game.corpses.size()==1,"Death persists a corpse container")
	check(game.bag.count_item("wood")==0,"Death transfers inventory out of carried slots")
	check(Save.validate(game.capture())=="","Dead world state validates")
	game.respawn()
	check(game.stats.health==100 and game.selected==0,"Respawn restores survival state and selected slot")
	game.recover_corpse(game.corpses[0].id)
	check(game.bag.count_item("wood")==carried,"Recovery preserves harvested items")
	check(game.corpses.is_empty(),"Recovered corpse container is removed")
	game.player.position.x += 1
	game.save_world(false)
	check(Save.validate(game.capture())=="","Live world serializes validly")
	check(game.save_count>0,"Real world saves to disk")
	await construction_scene_tests(game)
	game.queue_free()
	await process_frame
	finished = true
	watchdog_timer.time_left = 0
	await create_timer(0.05).timeout
	print("SOLOSURVIVAL_TESTS assertions=%d failures=%d" % [assertions,failures.size()])
	quit(0 if failures.is_empty() else 1)
