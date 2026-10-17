extends SceneTree
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

func run_tests() -> void:
	domain_tests()
	save_tests()
	var game = Game.new()
	root.add_child(game)
	await game.world_ready
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
	game.queue_free()
	await process_frame
	finished = true
	watchdog_timer.time_left = 0
	await create_timer(0.05).timeout
	print("SOLOSURVIVAL_TESTS assertions=%d failures=%d" % [assertions,failures.size()])
	quit(0 if failures.is_empty() else 1)
