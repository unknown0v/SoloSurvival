extends RefCounted
const Items = preload("res://scripts/core/items.gd")
const Inventory = preload("res://scripts/core/inventory.gd")
var jobs: Array = []

func enqueue(id: String, bag) -> bool:
	if not Items.RECIPES.has(id) or jobs.size() >= 8:
		return false
	var recipe: Dictionary = Items.RECIPES[id]
	if not bag.pay(recipe.cost):
		return false
	jobs.append({"id":id, "remaining":recipe.time})
	return true

func tick(delta: float, bag) -> String:
	if jobs.is_empty() or delta <= 0:
		return ""
	var job: Dictionary = jobs[0]
	job.remaining = maxf(0, float(job.remaining) - delta)
	var count: int = int(Items.RECIPES[job.id].amount)
	if float(job.remaining) > 0 or bag.capacity(job.id) < count:
		return ""
	bag.add(job.id, count)
	jobs.pop_front()
	return job.id

func cancel(index: int, bag) -> bool:
	if index < 0 or index >= jobs.size():
		return false
	var trial = Inventory.new(bag.slots.size())
	trial.slots = bag.slots.duplicate(true)
	var costs: Dictionary = Items.RECIPES[jobs[index].id].cost
	for id in costs:
		if trial.add(id, int(costs[id])) != 0:
			return false
	bag.slots = trial.slots
	jobs.remove_at(index)
	bag.changed.emit()
	return true

static func valid(raw: Variant) -> bool:
	if not raw is Array or raw.size() > 8:
		return false
	for job in raw:
		if not job is Dictionary or not Items.RECIPES.has(job.get("id", "")):
			return false
		var value: Variant = job.get("remaining")
		if not (value is int or value is float) or not is_finite(float(value)) or float(value) < 0 or float(value) > 120:
			return false
	return true
