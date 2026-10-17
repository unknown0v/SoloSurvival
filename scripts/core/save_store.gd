extends RefCounted
const Inventory = preload("res://scripts/core/inventory.gd")
const Settlement = preload("res://scripts/core/settlement.gd")
const Crafting = preload("res://scripts/core/crafting.gd")
const MAX_BYTES: int = 2097152
var path: String
var writable: bool = false
var message: String = ""
var last_text: String = ""

func _init(filename: String = "user://island-v1.json") -> void:
	path = filename

static func number(v: Variant, low: float, high: float) -> bool:
	return (v is int or v is float) and is_finite(float(v)) and float(v)>=low and float(v)<=high

static func position_valid(pos: Variant) -> bool:
	return pos is Array and pos.size()==3 and number(pos[0],-319,319) and number(pos[1],-20,160) and number(pos[2],-319,319)

static func validate(data: Variant) -> String:
	if not data is Dictionary:
		return "Save payload must be an object."
	if (data.get("version") != 1 and data.get("version") != 2 and data.get("version") != 3) or data.get("seed") != 197403:
		return "Unsupported world version or seed."
	if not position_valid(data.get("position")) or not number(data.get("yaw"),-100000,100000) or not number(data.get("pitch"),-1.5,1.5):
		return "Invalid player transform."
	if not number(data.get("hour"),0,24) or not number(data.get("elapsed"),0,100000000):
		return "Invalid clock."
	if not Inventory.valid(data.get("inventory"),36) or not Crafting.valid(data.get("jobs")):
		return "Invalid inventory or crafting queue."
	if not number(data.get("selected"),0,5) or floorf(float(data.selected)) != float(data.selected):
		return "Invalid selected slot."
	if not data.get("stats") is Dictionary:
		return "Missing survival stats."
	for key in ["health","hunger","thirst"]:
		if not number(data.stats.get(key),0,100):
			return "Invalid survival statistic."
	if not data.get("resources") is Dictionary or data.resources.size()>1000:
		return "Invalid resource collection."
	for id in data.resources:
		var r: Variant = data.resources[id]
		if not id is String or not id.is_valid_int() or not r is Dictionary:
			return "Invalid resource identity."
		if not number(r.get("hp"),0,200) or not number(r.get("respawn"),0,100000000):
			return "Invalid resource state."
	if data.version>=2 and not Settlement.valid(data.get("structures")):
		return "Invalid structures, support graph or station contents."
	if data.version==3:
		var maintenance: Variant = data.get("maintenance")
		if not maintenance is Dictionary or not number(maintenance.get("grace"),0,1800) or not number(maintenance.get("clock"),0,300):
			return "Invalid upkeep timer."
	# Older worlds remain readable; new worlds write version 3.
	if not data.get("corpses") is Array or data.corpses.size()>32:
		return "Invalid death containers."
	var seen: Dictionary = {}
	for corpse in data.corpses:
		if not corpse is Dictionary or not corpse.get("id") is String or corpse.id.length()>80 or seen.has(corpse.id):
			return "Invalid death container identity."
		seen[corpse.id] = true
		if not position_valid(corpse.get("position")) or not Inventory.valid(corpse.get("inventory"),36):
			return "Invalid death container contents."
	return ""

static func encode_save(data: Dictionary) -> String:
	var payload: String = JSON.stringify(data)
	return JSON.stringify({"format":1, "sha256":payload.sha256_text(), "payload":payload})

static func unwrap(text: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(text)!=OK:
		return {"error":"Malformed save JSON."}
	var envelope: Variant = parser.data
	if not envelope is Dictionary or envelope.get("format") != 1 or not envelope.get("payload") is String:
		return {"error":"Unrecognized save format."}
	if envelope.payload.sha256_text() != envelope.get("sha256"):
		return {"error":"Save integrity check failed."}
	var inner := JSON.new()
	if inner.parse(envelope.payload)!=OK:
		return {"error":"Malformed save payload."}
	var data: Variant = inner.data
	var error: String = validate(data)
	if error != "":
		return {"error":error, "unsupported":data is Dictionary and ((data.get("version") != 1 and data.get("version") != 2 and data.get("version") != 3) or data.get("seed") != 197403)}
	return {"data":data}

func read_file(filename: String) -> Dictionary:
	var file := FileAccess.open(filename,FileAccess.READ)
	if file == null:
		return {"error":"Cannot open save: "+error_string(FileAccess.get_open_error())}
	if file.get_length()>MAX_BYTES:
		file.close()
		return {"error":"Save exceeds 2 MiB safety limit."}
	var text: String = file.get_as_text()
	file.close()
	return unwrap(text)

func load_world() -> Dictionary:
	if not FileAccess.file_exists(path) and not FileAccess.file_exists(path+".bak"):
		writable = true
		return {}
	var primary: Dictionary = read_file(path)
	if primary.has("data"):
		writable = true
		message = "World restored."
		return primary.data
	if primary.get("unsupported",false):
		message = str(primary.error)+" Saving disabled; original preserved."
		return {}
	var backup: Dictionary = read_file(path+".bak")
	if backup.has("data"):
		if FileAccess.file_exists(path):
			var rejected: String = path+".rejected-"+str(Time.get_unix_time_from_system()).replace(".","-")
			if DirAccess.rename_absolute(path,rejected) != OK:
				message = "Could not preserve rejected save; saving disabled."
				return {}
		writable = true
		message = "Recovered backup; rejected save preserved."
		return backup.data
	message = str(primary.error)+" No usable backup. Saving disabled to preserve files."
	return {}

func write(data: Dictionary) -> bool:
	var reason: String = validate(data)
	if not writable or reason != "":
		message = "Saving disabled. "+reason
		return false
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null:
		message = "Cannot create save: "+error_string(FileAccess.get_open_error())
		return false
	var encoded: String = encode_save(data)
	file.store_string(encoded)
	file.flush()
	var result: Error = file.get_error()
	file.close()
	if result != OK:
		message = "Save write failed: "+error_string(result)
		return false
	if FileAccess.file_exists(path) and DirAccess.copy_absolute(path,path+".bak") != OK:
		message = "Cannot preserve backup; original retained."
		return false
	if DirAccess.rename_absolute(path+".tmp",path) != OK:
		message = "Cannot commit save; original retained."
		return false
	last_text = encoded
	message = "Saved on this device."
	return true

static func settlement_state(data: Dictionary) -> Dictionary:
	var state: Dictionary = {"pieces":[],"grace":1800.0,"clock":0.0}
	if data.version>=2:
		state.pieces = data.structures.duplicate(true)
	if data.version>=3:
		state.grace = float(data.maintenance.grace)
		state.clock = float(data.maintenance.clock)
	return state
