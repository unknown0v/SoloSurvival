extends RefCounted
const Items = preload("res://scripts/core/items.gd")
signal changed
var slots: Array = []

func _init(size: int = 36) -> void:
	for i in range(size):
		slots.append({})

func count_item(id: String) -> int:
	var total: int = 0
	for item in slots:
		if item.get("id", "") == id:
			total += int(item.count)
	return total

func capacity(id: String, condition: int = -1) -> int:
	if condition < 0:
		condition = int(Items.ITEMS[id].durability)
	var total: int = 0
	var limit: int = int(Items.ITEMS[id].stack)
	for item in slots:
		if item.is_empty():
			total += limit
		elif item.id == id and int(item.condition) == condition:
			total += limit - int(item.count)
	return total

# The caller retains ownership of the returned overflow.
func add(id: String, amount: int, condition: int = -1) -> int:
	if not Items.ITEMS.has(id) or amount <= 0:
		return amount
	if condition < 0:
		condition = int(Items.ITEMS[id].durability)
	var left: int = amount
	var limit: int = int(Items.ITEMS[id].stack)
	for item in slots:
		if item.get("id", "") == id and int(item.condition) == condition:
			var n: int = mini(left, limit - int(item.count))
			item.count += n
			left -= n
	for i in range(slots.size()):
		if left == 0:
			break
		if slots[i].is_empty():
			var n: int = mini(left, limit)
			slots[i] = {"id":id, "count":n, "condition":condition}
			left -= n
	if left != amount:
		changed.emit()
	return left

func remove(id: String, amount: int) -> bool:
	if amount < 0 or count_item(id) < amount:
		return false
	for i in range(slots.size()):
		if slots[i].get("id", "") != id:
			continue
		var n: int = mini(amount, int(slots[i].count))
		slots[i].count -= n
		amount -= n
		if int(slots[i].count) == 0:
			slots[i] = {}
		if amount == 0:
			break
	changed.emit()
	return true

func can_pay(cost: Dictionary) -> bool:
	for id in cost:
		if count_item(id) < int(cost[id]):
			return false
	return true

func pay(cost: Dictionary) -> bool:
	if not can_pay(cost):
		return false
	for id in cost:
		remove(id, int(cost[id]))
	return true

func transfer(from: int, target, to: int, half: bool = false) -> void:
	if from < 0 or from >= slots.size() or to < 0 or to >= target.slots.size() or (target == self and from == to):
		return
	var source: Dictionary = slots[from]
	var dest: Dictionary = target.slots[to]
	if source.is_empty():
		return
	var amount: int = ceili(int(source.count) / 2.0) if half else int(source.count)
	if dest.is_empty():
		target.slots[to] = source.duplicate()
		target.slots[to].count = amount
	elif dest.id == source.id and int(dest.condition) == int(source.condition):
		amount = mini(amount, int(Items.ITEMS[source.id].stack) - int(dest.count))
		dest.count += amount
	else:
		if half:
			return
		target.slots[to] = source
		slots[from] = dest
		changed.emit()
		target.changed.emit()
		return
	source.count -= amount
	if int(source.count) == 0:
		slots[from] = {}
	changed.emit()
	target.changed.emit()

func split(index: int) -> bool:
	if slots[index].is_empty() or int(slots[index].count) < 2:
		return false
	for i in range(slots.size()):
		if slots[i].is_empty():
			transfer(index, self, i, true)
			return true
	return false

static func valid(data: Variant, size: int) -> bool:
	if not data is Array or data.size() != size:
		return false
	for item in data:
		if not item is Dictionary:
			return false
		if item.is_empty():
			continue
		if not Items.ITEMS.has(item.get("id", "")):
			return false
		for key in ["count", "condition"]:
			if not item.has(key) or not (item[key] is int or item[key] is float):
				return false
			if not is_finite(float(item[key])) or float(item[key]) != floorf(float(item[key])):
				return false
		if int(item.count) < 1 or int(item.count) > int(Items.ITEMS[item.id].stack):
			return false
		if int(item.condition) < 0 or int(item.condition) > int(Items.ITEMS[item.id].durability):
			return false
	return true
