extends RefCounted
const Inventory = preload("res://scripts/core/inventory.gd")
const KINDS = ["foundation","wall","floor","roof","doorframe","door","storage","campfire","furnace"]
const COSTS = {
	"foundation":{"wood":30},"wall":{"wood":25},"floor":{"wood":25},"roof":{"wood":25},
	"doorframe":{"wood":20},"door":{"wood":40},"storage":{"wood":60},
	"campfire":{"wood":40,"stone":30},"furnace":{"wood":60,"stone":200}
}
const HEALTH = [80.0,250.0,600.0,1000.0]
const TIERS = ["Twig","Wood","Stone","Metal"]
const MAX_PIECES: int = 256
var pieces: Array = []
var serial: int = 0
signal changed

static func station(kind: String) -> bool:
	return kind in ["storage","campfire","furnace"]

static func same_cell(a: Dictionary, b: Dictionary) -> bool:
	return int(a.cell[0])==int(b.cell[0]) and int(a.cell[1])==int(b.cell[1]) and absf(float(a.y)-float(b.y))<0.05

static func horizontal(kind: String) -> bool:
	return kind in ["foundation","floor","roof"]

static func max_health(p: Dictionary) -> float:
	return 250.0 if station(p.kind) else HEALTH[int(p.tier)]

func find(id: String) -> Dictionary:
	for p in pieces:
		if p.id==id:
			return p
	return {}

func at_socket(candidate: Dictionary) -> Dictionary:
	for p in pieces:
		if not same_cell(p,candidate) or p.level!=candidate.level:
			continue
		if horizontal(p.kind) and horizontal(candidate.kind):
			return p
		if p.kind in ["wall","doorframe"] and candidate.kind in ["wall","doorframe"] and p.edge==candidate.edge:
			return p
		if p.kind==candidate.kind and p.edge==candidate.edge:
			return p
		# Opposite edges in adjoining cells describe the same physical wall.
	for p in pieces:
		if p.kind not in ["wall","doorframe"] or candidate.kind not in ["wall","doorframe"]:
			continue
		var step: Vector2i = edge_step(int(candidate.edge))
		if int(p.cell[0])==int(candidate.cell[0])+step.x and int(p.cell[1])==int(candidate.cell[1])+step.y and p.edge==(int(candidate.edge)+2)%4 and p.level==candidate.level and absf(float(p.y)-float(candidate.y))<0.05:
			return p
	return {}

static func edge_step(edge: int) -> Vector2i:
	return [Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0)][edge]

func make_piece(kind: String, cell: Array, y: float, level: int, edge: int) -> Dictionary:
	return {"id":"","kind":kind,"cell":cell.duplicate(),"y":y,"level":level,"edge":edge,"tier":0,"hp":250.0 if station(kind) else 80.0,"open":false,"inventory":Inventory.new(12 if station(kind) else 0).slots,"active":false,"progress":0.0}

# A monotone support calculation cannot make a disconnected cycle support itself.
func supports(records: Array) -> Dictionary:
	var strength: Dictionary = {}
	for p in records:
		strength[p.id] = 1.0 if p.kind=="foundation" and p.level==0 else 0.0
	for iteration in range(16):
		var advanced: bool = false
		for p in records:
			if p.kind=="foundation":
				continue
			var best: float = float(strength[p.id])
			for source in records:
				var value: float = float(strength[source.id])
				if value<=0 or p.id==source.id:
					continue
				if same_cell(p,source):
					if p.kind in ["wall","doorframe","storage","campfire","furnace"] and source.kind in ["foundation","floor"] and source.level==p.level:
						best = maxf(best,value-0.08)
					elif p.kind=="door" and source.kind=="doorframe" and source.level==p.level and source.edge==p.edge:
						best = maxf(best,value-0.04)
					elif p.kind in ["floor","roof"] and source.kind in ["wall","doorframe"] and source.level+1==p.level:
						best = maxf(best,value-0.08)
				elif p.kind in ["floor","roof"] and source.kind=="floor" and source.level==p.level and absf(float(p.y)-float(source.y))<0.05:
					var distance: int = absi(int(p.cell[0])-int(source.cell[0]))+absi(int(p.cell[1])-int(source.cell[1]))
					if distance==1:
						best = maxf(best,value-0.35)
			if best>float(strength[p.id])+0.001:
				strength[p.id] = best
				advanced = true
		if not advanced:
			break
	return strength

func reason(candidate: Dictionary) -> String:
	if pieces.size()>=MAX_PIECES:
		return "Structure limit reached (256)."
	if not at_socket(candidate).is_empty():
		return "That socket is occupied."
	var test: Dictionary = candidate.duplicate(true)
	test.id = "@preview"
	var all: Array = pieces.duplicate()
	all.append(test)
	if float(supports(all).get(test.id,0))<0.2:
		return "No structural support. Build a foundation or supporting walls."
	return ""

func place(candidate: Dictionary, bag) -> Dictionary:
	if reason(candidate)!="" or not bag.can_pay(COSTS[candidate.kind]):
		return {}
	serial += 1
	while not find("b"+str(serial)).is_empty():
		serial += 1
	var p: Dictionary = candidate.duplicate(true)
	p.id = "b"+str(serial)
	if not bag.pay(COSTS[p.kind]):
		return {}
	pieces.append(p)
	changed.emit()
	return p

func upgrade_cost(p: Dictionary) -> Dictionary:
	if station(p.kind) or int(p.tier)>=3:
		return {}
	return [{"wood":80},{"stone":120},{"metal":60}][int(p.tier)].duplicate()

func upgrade(id: String, bag) -> bool:
	var p: Dictionary = find(id)
	if p.is_empty():
		return false
	var cost: Dictionary = upgrade_cost(p)
	if cost.is_empty() or not bag.pay(cost):
		return false
	p.tier += 1
	p.hp = max_health(p)
	changed.emit()
	return true

func repair(id: String, bag) -> bool:
	var p: Dictionary = find(id)
	if p.is_empty() or float(p.hp)>=max_health(p):
		return false
	var resource: String = "wood" if int(p.tier)<2 else "stone" if int(p.tier)==2 else "metal"
	var cost: int = maxi(1,ceili((max_health(p)-float(p.hp))/max_health(p)*20))
	if not bag.remove(resource,cost):
		return false
	p.hp = max_health(p)
	changed.emit()
	return true

func collapse_set(id: String) -> Array:
	var remaining: Array = pieces.filter(func(p): return p.id!=id)
	var strength: Dictionary = supports(remaining)
	var lost: Array = [id]
	for p in remaining:
		if float(strength[p.id])<0.2:
			lost.append(p.id)
	return lost

func dismantle(id: String) -> bool:
	if find(id).is_empty():
		return false
	var lost: Array = collapse_set(id)
	for p in pieces:
		if p.id in lost and p.inventory.any(func(s): return not s.is_empty()):
			return false
	pieces = pieces.filter(func(p): return p.id not in lost)
	changed.emit()
	return true

# Destruction with stored items is blocked in this single-player milestone.
# This preserves ownership until the player can empty the affected containers.
func strike(id: String, amount: float) -> bool:
	var p: Dictionary = find(id)
	if p.is_empty():
		return false
	if float(p.hp)>amount:
		p.hp -= amount
		changed.emit()
		return true
	return dismantle(id)

func tick(dt: float) -> void:
	for p in pieces:
		if p.kind not in ["campfire","furnace"] or not p.active:
			continue
		var inv = Inventory.new(12)
		inv.slots = p.inventory
		var input: String = "berries" if p.kind=="campfire" else "ore"
		var output: String = "cooked_berries" if p.kind=="campfire" else "metal"
		var duration: float = 5.0 if p.kind=="campfire" else 8.0
		if inv.count_item(input)<2 or inv.count_item("wood")<1 or inv.capacity(output)<1:
			continue
		p.progress = minf(float(p.progress)+dt,duration)
		if float(p.progress)>=duration:
			# Reserve capacity before consuming. One completed batch per tick.
			inv.remove(input,2)
			inv.remove("wood",1)
			inv.add(output,1)
			p.progress = 0.0
			changed.emit()

static func valid(data: Variant) -> bool:
	if not data is Array or data.size()>MAX_PIECES:
		return false
	var ids: Dictionary = {}
	var model = load("res://scripts/core/settlement.gd").new()
	for p in data:
		if not p is Dictionary or not p.get("id") is String or p.id.length()<1 or p.id.length()>40 or ids.has(p.id):
			return false
		ids[p.id] = true
		if p.get("kind") not in KINDS or not p.get("cell") is Array or p.cell.size()!=2:
			return false
		for v in p.cell:
			if not numeric(v,-100,100) or float(v)!=floorf(float(v)):
				return false
		if not numeric(p.get("y"),0,120) or not numeric(p.get("level"),0,4) or float(p.level)!=floorf(float(p.level)):
			return false
		if not numeric(p.get("edge"),0,3) or float(p.edge)!=floorf(float(p.edge)) or not numeric(p.get("tier"),0,3) or float(p.tier)!=floorf(float(p.tier)):
			return false
		if station(p.kind) and p.tier!=0:
			return false
		if p.kind=="foundation" and p.level!=0 or p.kind in ["floor","roof"] and p.level==0:
			return false
		if not numeric(p.get("hp"),0.001,max_health(p)) or not p.get("open") is bool or not p.get("active") is bool:
			return false
		if not numeric(p.get("progress"),0,8) or not Inventory.valid(p.get("inventory"),12 if station(p.kind) else 0):
			return false
		if not model.at_socket(p).is_empty():
			return false
		model.pieces.append(p)
	var strength: Dictionary = model.supports(data)
	for p in data:
		if float(strength[p.id])<0.2:
			return false
	return true

static func numeric(v: Variant, low: float, high: float) -> bool:
	return (v is float or v is int) and is_finite(float(v)) and float(v)>=low and float(v)<=high
