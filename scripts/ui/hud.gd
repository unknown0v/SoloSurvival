extends CanvasLayer
const Slot = preload("res://scripts/ui/item_slot.gd")
var game
var station_panel: VBoxContainer
var station_title: Label
var station_status: Label
var station_grid: GridContainer
var station_slots: Array = []
var station_inventory
var station_toggle: Button
var tabs: TabContainer
var ui_buttons: Dictionary = {}
var root: Control
var title: PanelContainer
var title_text: Label
var start_button: Button
var menu: PanelContainer
var hotbar: HBoxContainer
var all_slots: Array = []
var stat_labels: Dictionary = {}
var bars: Dictionary = {}
var recipe_buttons: Dictionary = {}
var queue_buttons: Array = []
var message: Label
var prompt: Label
var clock: Label
var dead: PanelContainer
var warning: Label
var message_time: float = 0
var refresh_timer: float = 0

func label(text: String, size: int = 16, color: Color = Color("#e0e4d9")) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size",size)
	node.add_theme_color_override("font_color",color)
	return node

func button(text: String, action: Callable) -> Button:
	var node := Button.new()
	node.text = text
	ui_buttons[text] = node
	node.custom_minimum_size.y = 38
	node.focus_mode = Control.FOCUS_NONE
	node.pressed.connect(action)
	return node

func skin(panel: Control, color: Color = Color("#14201ef2")) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("#62705b")
	style.set_border_width_all(1)
	style.set_content_margin_all(22)
	panel.add_theme_stylebox_override("panel",style)

func setup(owner_game) -> void:
	game = owner_game
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var header := label("SOLO SURVIVAL   /   FIELD JOURNAL",16,Color("#d8c79c"))
	header.position = Vector2(28,22)
	root.add_child(header)
	clock = label("",14)
	clock.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	clock.position = Vector2(-200,24)
	root.add_child(clock)
	var crosshair := label("+",22,Color("#e8ede1"))
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.position = Vector2(-7,-16)
	root.add_child(crosshair)
	prompt = label("",15,Color("#e6d9b7"))
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	prompt.position = Vector2(-240,56)
	prompt.custom_minimum_size.x = 480
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(prompt)
	message = label("",16,Color("#e1d3ae"))
	message.position = Vector2(28,64)
	root.add_child(message)
	warning = label("",13,Color("#edb99e"))
	warning.position = Vector2(28,91)
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning.custom_minimum_size.x = 900
	root.add_child(warning)
	hotbar = HBoxContainer.new()
	hotbar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	hotbar.position = Vector2(-222,-80)
	hotbar.add_theme_constant_override("separation",5)
	root.add_child(hotbar)
	for i in range(6):
		var slot := Slot.new()
		slot.setup(game,game.bag,i,true)
		hotbar.add_child(slot)
		all_slots.append(slot)
	var hint := label("WASD  MOVE     SHIFT  RUN     CTRL  CROUCH     SPACE  JUMP     TAB  INVENTORY     E  INTERACT     F5  SAVE",11,Color("#b0beb3"))
	hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	hint.position = Vector2(-500,-18)
	root.add_child(hint)
	var stats := VBoxContainer.new()
	stats.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	stats.position = Vector2(-220,-163)
	stats.custom_minimum_size.x = 192
	root.add_child(stats)
	for key in ["health","hunger","thirst"]:
		var text := label("",13)
		stats.add_child(text)
		stat_labels[key] = text
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(192,9)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color("#a1b18c") if key=="health" else Color("#c4a977") if key=="hunger" else Color("#7da6ad")
		bar.add_theme_stylebox_override("fill",fill)
		stats.add_child(bar)
		bars[key] = bar
	build_title()
	build_inventory()
	dead = PanelContainer.new()
	dead.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	dead.position = Vector2(-300,-140)
	dead.custom_minimum_size = Vector2(600,260)
	skin(dead)
	root.add_child(dead)
	var d := VBoxContainer.new()
	d.add_theme_constant_override("separation",14)
	dead.add_child(d)
	d.add_child(label("YOU FELL",38,Color("#dec099")))
	d.add_child(label("Your belongings remain at your last position.\nThe island continues.",17))
	d.add_child(button("RETURN TO SHORE",game.respawn))
	dead.hide()
	game.bag.changed.connect(refresh)
	refresh()

func build_title() -> void:
	title = PanelContainer.new()
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	title.position = Vector2(-330,-225)
	title.custom_minimum_size = Vector2(660,450)
	skin(title)
	root.add_child(title)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",18)
	title.add_child(content)
	content.add_child(label("ONE ISLAND. YOUR OWN SURVIVAL.",13,Color("#a7b196")))
	title_text = label("SOLO\nSURVIVAL",58,Color("#e2d4b2"))
	content.add_child(title_text)
	content.add_child(label("A quiet shore. A rough stone. A world worth building.\nGather, craft and survive on a persistent offline island.",17))
	start_button = button("EMBARK  /  ENTER",game.start_playing)
	start_button.custom_minimum_size.y = 52
	content.add_child(start_button)
	content.add_child(button("SAVE WORLD",func(): game.save_world()))
	content.add_child(button("TOGGLE DYNAMIC SHADOWS",func(): game.sun.shadow_enabled = not game.sun.shadow_enabled))
	content.add_child(button("DOWNLOAD SAVE BACKUP",game.download_save))
	if OS.has_feature("web"):
		content.add_child(button("RESTORE SAVE BACKUP",game.import_backup))
	content.add_child(label("Independent work in progress · Original procedural art\nBrowser saves belong to this browser and origin. Keep a backup.",12,Color("#a3afa4")))

func build_inventory() -> void:
	menu = PanelContainer.new()
	menu.position = Vector2(45,45)
	menu.size = Vector2(1190,610)
	skin(menu)
	root.add_child(menu)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",20)
	menu.add_child(row)
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 460
	row.add_child(left)
	left.add_child(label("YOUR INVENTORY",24,Color("#e2d4b2")))
	left.add_child(label("Drag to move · Shift-drag half · Right click split",12))
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation",5)
	grid.add_theme_constant_override("v_separation",5)
	left.add_child(grid)
	for i in range(36):
		var slot := Slot.new()
		slot.setup(game,game.bag,i)
		grid.add_child(slot)
		all_slots.append(slot)
	left.add_child(button("USE SELECTED ITEM",func(): game.use_item(game.inspected_slot)))
	left.add_child(button("SAVE AND RETURN  /  TAB",func():
		game.save_world()
		game.toggle_inventory()
	))
	tabs = TabContainer.new()
	tabs.custom_minimum_size = Vector2(640,550)
	row.add_child(tabs)
	var scroll := ScrollContainer.new()
	scroll.name = "Crafting"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(scroll)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(right)
	right.add_child(label("CRAFTING",24,Color("#e2d4b2")))
	right.add_child(label("Ingredients reserved on queue. Scroll for recipes.",13))
	for id in game.items.RECIPES:
		var recipe: Dictionary = game.items.RECIPES[id]
		var cost: String = ""
		for input in recipe.cost:
			cost += "%d %s  " % [recipe.cost[input],game.items.ITEMS[input].name]
		var text: String = "%s  ·  %ds\n%s" % [game.items.ITEMS[id].name,int(recipe.time),cost]
		var recipe_id: String = str(id)
		var recipe_button := button(text,func(): game.queue_craft(recipe_id))
		recipe_button.custom_minimum_size.y = 54
		right.add_child(recipe_button)
		recipe_buttons[id] = recipe_button
	right.add_child(label("QUEUE / CLICK TO CANCEL AND REFUND",13,Color("#a6b59d")))
	for i in range(8):
		var index: int = i
		var job_button := button("",func():
			if not game.crafts.cancel(index,game.bag):
				game.say("Refund needs more inventory room.")
		)
		job_button.custom_minimum_size.y = 24
		job_button.add_theme_font_size_override("font_size",12)
		right.add_child(job_button)
		queue_buttons.append(job_button)
	var guide := VBoxContainer.new()
	guide.name = "Building guide"
	tabs.add_child(guide)
	guide.add_child(label("BUILD YOUR SHORELINE HOME",24))
	guide.add_child(label("Craft a building plan and hammer. Press B to build.\n1 foundation · 2 wall · 3 floor · 4 roof\n5 doorframe · 6 door · 7 storage · 8 fire · 9 furnace\nR rotates; green preview = valid; left click places.\n\nFoundations need dry, flat ground. Walls stand on\nfoundations/floors. Floors/roofs sit above walls.\nDoors fit doorframes; stations sit on platforms.\nAim at the supporting section to select its level.\n\nHammer selected: click repair · U upgrade · X dismantle.\nTwig → wood → stone → metal. Aim for costs/status.\nRemoving support collapses unsupported pieces.\nEmpty ALL affected containers before dismantling.\nNo demolition refund. Max 256 pieces, four storeys.\n\nE opens a station or toggles a door. Drag items between\nyour bag and its slots. Fire: 2 berries + 1 wood → ration.\nFurnace: 2 ore + 1 wood → metal. Start the station.\nOutputs wait when full; no offline processing.",16))
	station_panel = VBoxContainer.new()
	station_panel.name = "Container"
	tabs.add_child(station_panel)
	station_title = label("AIM AT A STATION AND PRESS E",22)
	station_panel.add_child(station_title)
	station_status = label("",15)
	station_panel.add_child(station_status)
	station_grid = GridContainer.new()
	station_grid.columns = 6
	station_panel.add_child(station_grid)
	station_toggle = button("START / STOP PROCESSING",game.toggle_station)
	station_panel.add_child(station_toggle)
	station_panel.add_child(button("DEPOSIT ALL THAT FITS",func(): game.station_transfer(true)))
	station_panel.add_child(button("TAKE ALL THAT FITS",func(): game.station_transfer(false)))
	menu.hide()

func show_station(id: String) -> void:
	var p: Dictionary = game.settlement.find(id)
	if p.is_empty():
		return
	for slot in station_slots:
		station_grid.remove_child(slot)
		slot.queue_free()
	station_slots.clear()
	station_inventory = game.Inventory.new(12)
	station_inventory.slots = p.inventory
	for i in range(12):
		var slot := Slot.new()
		slot.setup(game,station_inventory,i)
		station_grid.add_child(slot)
		station_slots.append(slot)
	tabs.current_tab = 2
	refresh_station()

func refresh_station() -> void:
	var p: Dictionary = game.settlement.find(game.station_id)
	var available: bool = not p.is_empty()
	station_title.text = p.kind.to_upper() if available else "AIM AT A STATION AND PRESS E"
	station_grid.visible = available
	station_toggle.visible = available and p.kind!="storage"
	station_status.text = ("RUNNING" if p.active else "STOPPED")+" · "+str(snappedf(float(p.progress),0.1))+" s\n"+("2 berries + 1 wood → ration (5 s)" if p.kind=="campfire" else "2 ore + 1 wood → metal (8 s)" if p.kind=="furnace" else "12 slots · contents save with the world") if available else ""
	for slot in station_slots:
		slot.refresh()

func diagnostics() -> Dictionary:
	var result: Dictionary = {}
	for key in ui_buttons:
		var node: Button = ui_buttons[key]
		if is_instance_valid(node) and node.is_visible_in_tree() and key!="":
			var rect: Rect2 = node.get_global_rect()
			result[key] = [rect.get_center().x,rect.get_center().y]
	var size: Vector2 = get_viewport().get_visible_rect().size
	return {"buttons":result,"size":[size.x,size.y]}

func refresh() -> void:
	if station_panel!=null:
		refresh_station()
	for slot in all_slots:
		slot.refresh()
	for id in recipe_buttons:
		recipe_buttons[id].disabled = not game.bag.can_pay(game.items.RECIPES[id].cost) or game.crafts.jobs.size()>=8
	for i in range(queue_buttons.size()):
		var b: Button = queue_buttons[i]
		b.visible = i<game.crafts.jobs.size()
		if b.visible:
			var job: Dictionary = game.crafts.jobs[i]
			b.text = "%s  /  %ds%s" % [game.items.ITEMS[job.id].name,ceili(job.remaining),"  (waiting for bag space)" if job.remaining<=0 else ""]

func say(text: String) -> void:
	message.text = text
	message_time = 5

func _process(dt: float) -> void:
	if game==null:
		return
	message_time -= dt
	message.visible = message_time>0
	if not game.ready_to_play:
		return
	title.visible = not game.playing or game.paused
	title_text.text = "TAKE A\nBREATHER" if game.paused else "SOLO\nSURVIVAL"
	start_button.text = "RESUME  /  ENTER" if game.paused else "EMBARK  /  ENTER"
	menu.visible = game.menu_open
	dead.visible = float(game.stats.health)<=0
	if dead.visible:
		title.hide()
		menu.hide()
	prompt.text = game.prompt if game.playing and not game.menu_open and not game.paused else ""
	clock.text = "DAY %02d    %02d:%02d" % [1+int(game.elapsed/1800),int(game.hour),int(fmod(game.hour,1)*60)]
	for key in stat_labels:
		stat_labels[key].text = "%s  %d" % [str(key).to_upper(),ceili(game.stats[key])]
		bars[key].value = game.stats[key]
	refresh_timer -= dt
	if refresh_timer<=0:
		refresh_timer = 0.2
		refresh()
