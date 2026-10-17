extends Button
var game
var inventory
var index: int
var compact: bool = false

func setup(owner_game, bag, slot: int, small: bool = false) -> void:
	game = owner_game
	inventory = bag
	index = slot
	compact = small
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(70,60 if small else 54)
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_theme_font_size_override("font_size",12)
	pressed.connect(func():
		if index<6:
			game.select_slot(index)
		game.inspected_slot = index
	)
	refresh()

func refresh() -> void:
	var stack: Dictionary = inventory.slots[index]
	var prefix: String = str(index+1)+"  " if index<6 else ""
	if stack.is_empty():
		text = prefix+"—"
		tooltip_text = "Empty slot. Drag an item here."
		modulate = Color("#82918f")
	else:
		var def: Dictionary = game.items.ITEMS[stack.id]
		text = prefix+str(def.name)+"\n"+str(stack.count)
		if int(def.durability)>0:
			text += "  ·  "+str(int(stack.condition)*100/int(def.durability))+"%"
		tooltip_text = str(def.name)+"\n"+str(def.description)+"\nDrag to move · right click to split"
		modulate = Color("#"+str(def.color)).lightened(0.15)
	if compact and index==game.selected:
		modulate = Color("#e2d3ac")

func _get_drag_data(_position: Vector2) -> Variant:
	if not game.menu_open or inventory.slots[index].is_empty():
		return null
	var preview := Label.new()
	preview.text = str(game.items.ITEMS[inventory.slots[index].id].name)
	preview.modulate = Color("#e2d3ac")
	set_drag_preview(preview)
	return {"inventory":inventory,"slot":index}

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	return game.menu_open and data is Dictionary and data.has("inventory") and data.has("slot")

func _drop_data(_position: Vector2, data: Variant) -> void:
	data.inventory.transfer(int(data.slot),inventory,index,Input.is_physical_key_pressed(KEY_SHIFT))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT and game.menu_open:
		inventory.split(index)
		accept_event()
