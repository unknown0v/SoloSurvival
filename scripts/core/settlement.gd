extends RefCounted
const Inventory = preload("res://scripts/core/inventory.gd")
const KINDS = ["foundation","wall","floor","roof","doorframe","door","storage","campfire","furnace","cupboard","sleeping_bag","workbench","half_wall","window_frame","stairs","bed"]
const WALLS = ["wall","doorframe","half_wall","window_frame"]
const BEARING_WALLS = ["wall","doorframe","window_frame"]
const COSTS = {
	"foundation":{"wood":30},"wall":{"wood":25},"floor":{"wood":25},"roof":{"wood":25},
	"doorframe":{"wood":20},"door":{"wood":40},"storage":{"wood":60},
	"campfire":{"wood":40,"stone":30},"furnace":{"wood":60,"stone":200},
	"cupboard":{"wood":250,"stone":50},"sleeping_bag":{"wood":50,"cloth":30},"workbench":{"wood":300,"metal":100},"half_wall":{"wood":15},"window_frame":{"wood":25},"stairs":{"wood":50},"bed":{"wood":200,"cloth":50,"metal":30}
}
const HEALTH = [80.0,250.0,600.0,1000.0]
const TIERS = ["Twig","Wood","Stone","Metal"]
const MAX_PIECES: int = 256
const MAX_LEVEL: int = 4
var pieces: Array = []
var serial: int = 0
var upkeep_clock: float = 0
var upkeep_grace: float = 1800
var batching: bool = false
var dirty: bool = false
signal changed

static func station(kind: String) -> bool:
	return kind in ["storage","campfire","furnace","cupboard"]

static func deployable(kind: String) -> bool:
	return station(kind) or kind in ["sleeping_bag","bed","workbench"]

static func same_cell(a: Dictionary, b: Dictionary) -> bool:
	return int(a.cell[0])==int(b.cell[0]) and int(a.cell[1])==int(b.cell[1]) and absf(float(a.y)-float(b.y))<0.05

static func horizontal(kind: String) -> bool:
	return kind in ["foundation","floor","roof"]

static func max_health(p: Dictionary) -> float:
	return 250.0 if deployable(p.kind) else HEALTH[int(p.tier)]

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
		if p.kind in WALLS and candidate.kind in WALLS and p.edge==candidate.edge:
			return p
		if p.kind==candidate.kind and p.edge==candidate.edge:
			return p
		# Opposite edges in adjoining cells describe the same physical wall.
	for p in pieces:
		if p.kind not in WALLS or candidate.kind not in WALLS:
			continue
		var step: Vector2i = edge_step(int(candidate.edge))
		if int(p.cell[0])==int(candidate.cell[0])+step.x and int(p.cell[1])==int(candidate.cell[1])+step.y and p.edge==(int(candidate.edge)+2)%4 and p.level==candidate.level and absf(float(p.y)-float(candidate.y))<0.05:
			return p
	return {}

static func edge_step(edge: int) -> Vector2i:
	return [Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0)][edge]

func make_piece(kind: String, cell: Array, y: float, level: int, edge: int) -> Dictionary:
	return {"id":"","kind":kind,"cell":cell.duplicate(),"y":y,"level":level,"edge":edge,"tier":0,"hp":250.0 if deployable(kind) else 80.0,"open":false,"inventory":Inventory.new(12 if station(kind) else 0).slots,"active":false,"progress":0.0,"respawn":false}

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
					if (p.kind in WALLS or p.kind=="stairs" or deployable(p.kind)) and source.kind in ["foundation","floor"] and source.level==p.level:
						best = maxf(best,value-0.08)
					elif p.kind=="door" and source.kind=="doorframe" and source.level==p.level and source.edge==p.edge:
						best = maxf(best,value-0.04)
					elif p.kind in ["floor","roof"] and source.kind in BEARING_WALLS and source.level+1==p.level:
						best = maxf(best,value-0.08)
				elif landing_on_stairs(p,source):
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
	if candidate.kind not in KINDS or int(candidate.level)<0 or int(candidate.level)>MAX_LEVEL:
		return "Unknown piece or building height limit."
	if pieces.size()>=MAX_PIECES:
		return "Structure limit reached (256)."
	if not at_socket(candidate).is_empty():
		return "That socket is occupied."
	for p in pieces:
		if same_cell(p,candidate) and ((candidate.kind in ["floor","roof"] and p.kind=="stairs" and candidate.level==p.level+1) or (candidate.kind=="stairs" and p.kind in ["floor","roof"] and p.level==candidate.level+1)):
			return "Leave an open stairwell above stairs."
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
	notify_changed()
	return p

func upgrade_cost(p: Dictionary) -> Dictionary:
	if deployable(p.kind) or int(p.tier)>=3:
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
	notify_changed()
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
	notify_changed()
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
	notify_changed()
	return true

# Destruction with stored items is blocked in this single-player milestone.
# This preserves ownership until the player can empty the affected containers.
func strike(id: String, amount: float) -> bool:
	if not is_finite(amount) or amount<=0:
		return false
	var p: Dictionary = find(id)
	if p.is_empty():
		return false
	if float(p.hp)>amount:
		p.hp -= amount
		notify_changed()
		return true
	return dismantle(id)

func tick(dt: float) -> void:
	if not is_finite(dt) or dt<=0:
		return
	batching = true
	tick_upkeep(dt)
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
			notify_changed()
	batching = false
	if dirty:
		notify_changed()

static func valid(data: Variant) -> bool:
	if not data is Array or data.size()>MAX_PIECES:
		return false
	var ids: Dictionary = {}
	var respawns: int = 0
	var model = load("res://scripts/core/settlement.gd").new()
	for p in data:
		if not p is Dictionary or not p.get("id") is String or p.id.length()<1 or p.id.length()>40 or ids.has(p.id):
			return false
		ids[p.id] = true
		if not p.get("respawn",false) is bool:
			return false
		if p.get("respawn",false):
			if p.get("kind") not in ["sleeping_bag","bed"]:
				return false
			respawns += 1
			if respawns>1:
				return false
		if p.get("kind") not in KINDS or not p.get("cell") is Array or p.cell.size()!=2:
			return false
		for v in p.cell:
			if not numeric(v,-100,100) or float(v)!=floorf(float(v)):
				return false
		if not numeric(p.get("y"),0,120) or not numeric(p.get("level"),0,MAX_LEVEL) or float(p.level)!=floorf(float(p.level)):
			return false
		if not numeric(p.get("edge"),0,3) or float(p.edge)!=floorf(float(p.edge)) or not numeric(p.get("tier"),0,3) or float(p.tier)!=floorf(float(p.tier)):
			return false
		if deployable(p.kind) and p.tier!=0:
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

func connected(id: String) -> Array:
	var start: Dictionary = find(id)
	if start.is_empty():
		return []
	var result: Array = [id]
	var cursor: int = 0
	while cursor<result.size():
		var a: Dictionary = find(result[cursor])
		for b in pieces:
			if b.id in result or absf(float(a.y)-float(b.y))>0.05:
				continue
			var distance: int = absi(int(a.cell[0])-int(b.cell[0]))+absi(int(a.cell[1])-int(b.cell[1]))
			if distance<=1:
				result.append(b.id)
		cursor += 1
	return result

func upkeep_cost(ids: Array) -> Dictionary:
	var cost: Dictionary = {}
	for p in pieces:
		if p.id not in ids or deployable(p.kind):
			continue
		var material: String = "wood" if int(p.tier)<2 else "stone" if int(p.tier)==2 else "metal"
		cost[material] = int(cost.get(material,0))+1
	return cost

func tick_upkeep(dt: float) -> void:
	if upkeep_grace>0:
		var used: float = minf(upkeep_grace,dt)
		upkeep_grace -= used
		dt -= used
	upkeep_clock += minf(dt,300)
	if upkeep_clock<300:
		return
	upkeep_clock -= 300
	var examined: Array = []
	var changed_any: bool = false
	for root in pieces.duplicate():
		if root.id in examined or find(root.id).is_empty():
			continue
		var ids: Array = connected(root.id)
		examined.append_array(ids)
		var costs: Dictionary = upkeep_cost(ids)
		var cupboards: Array = []
		for id in ids:
			var p: Dictionary = find(id)
			if p.kind=="cupboard":
				var resources = Inventory.new(12)
				resources.slots = p.inventory
				cupboards.append(resources)
		var paid: Dictionary = {}
		for material in costs:
			var available: int = 0
			for resources in cupboards:
				available += resources.count_item(material)
			if available<int(costs[material]):
				continue
			var required: int = int(costs[material])
			for resources in cupboards:
				var amount: int = mini(required,resources.count_item(material))
				resources.remove(material,amount)
				required -= amount
			paid[material] = true
			changed_any = true
		for id in ids:
			var p: Dictionary = find(id)
			if p.is_empty() or deployable(p.kind):
				continue
			var material: String = "wood" if int(p.tier)<2 else "stone" if int(p.tier)==2 else "metal"
			if not paid.has(material):
				# Single-player tuning; no offline decay. Nonempty collapse protection remains.
				if strike(id,max_health(p)*[0.10,0.06,0.04,0.025][int(p.tier)]):
					changed_any = true
	if changed_any:
		notify_changed()

func bind_spawn(id: String) -> bool:
	var target: Dictionary = find(id)
	if target.is_empty() or target.kind not in ["sleeping_bag","bed"]:
		return false
	for p in pieces:
		p.respawn = p.id==id
	notify_changed()
	return true

func respawn_piece() -> Dictionary:
	for p in pieces:
		if p.kind in ["sleeping_bag","bed"] and p.get("respawn",false):
			return p
	return {}

func notify_changed() -> void:
	dirty = true
	if not batching:
		dirty = false
		changed.emit()

static func landing_on_stairs(floor_piece: Dictionary, stairs: Dictionary) -> bool:
	if floor_piece.kind!="floor" or stairs.kind!="stairs" or floor_piece.level!=stairs.level+1 or absf(float(floor_piece.y)-float(stairs.y))>0.05:
		return false
	var step: Vector2i = edge_step(int(stairs.edge))
	return int(floor_piece.cell[0])==int(stairs.cell[0])+step.x and int(floor_piece.cell[1])==int(stairs.cell[1])+step.y
