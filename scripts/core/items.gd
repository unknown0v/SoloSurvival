extends RefCounted

const ITEMS = {
	"metal_pickaxe": {"name":"Metal pickaxe","stack":1,"durability":800,"color":"a7bbc0","description":"Workbench-crafted metal tool. Mines stone and ore efficiently."},
	"building_plan": {"name":"Building plan","stack":1,"durability":0,"color":"91bac6","description":"Press B to build. Choose a piece with 1–9, rotate with R, place with left click."},
	"hammer": {"name":"Building hammer","stack":1,"durability":300,"color":"b39264","description":"Left click repairs, U upgrades, X dismantles. Empty affected containers first."},
	"metal": {"name":"Metal fragments","stack":1000,"durability":0,"color":"a7b1b8","description":"Smelt 2 ore with 1 wood in a furnace. Used for metal upgrades."},
	"cooked_berries": {"name":"Cooked berry ration","stack":20,"durability":0,"color":"cd9667","description":"Cook 2 berries with 1 wood in a campfire. Restores 32 hunger and 4 health."},
	"rock": {"name":"Rock", "stack":1, "durability":300, "color":"9aa5a4", "description":"A crude gathering tool. Strike trees and stone nodes."},
	"torch": {"name":"Torch", "stack":1, "durability":0, "color":"dea15d", "description":"Select to light the night."},
	"wood": {"name":"Wood", "stack":1000, "durability":0, "color":"b39264", "description":"Gather from trees. Construction and fuel."},
	"stone": {"name":"Stone", "stack":1000, "durability":0, "color":"a8b2b6", "description":"Gather from pale mineral nodes."},
	"ore": {"name":"Metal ore", "stack":1000, "durability":0, "color":"aa805a", "description":"Metal-bearing stone. Smelt in a fueled furnace."},
	"cloth": {"name":"Cloth", "stack":500, "durability":0, "color":"bbbea1", "description":"Harvest wild hemp for tools and bandages."},
	"berries": {"name":"Wild berries", "stack":20, "durability":0, "color":"c57985", "description":"Use to restore food and hydration."},
	"water": {"name":"Water flask", "stack":5, "durability":0, "color":"7fb6c1", "description":"Use to restore hydration. Drink directly from the river with E."},
	"axe": {"name":"Stone hatchet", "stack":1, "durability":400, "color":"a4b4a1", "description":"Crafted tool. Harvests wood three times as efficiently."},
	"pickaxe": {"name":"Stone pickaxe", "stack":1, "durability":400, "color":"9aabbf", "description":"Crafted tool. Mines stone and ore efficiently."},
	"bandage": {"name":"Bandage", "stack":10, "durability":0, "color":"d0cbb9", "description":"Use to recover 20 health."}
}
const RECIPES = {
	"metal_pickaxe": {"amount":1,"time":8.0,"bench":1,"cost":{"wood":100,"metal":50,"cloth":10}},
	"building_plan": {"amount":1,"time":1.0,"cost":{"wood":20}},
	"hammer": {"amount":1,"time":3.0,"cost":{"wood":80,"stone":30}},
	"axe": {"amount":1, "time":4.0, "cost":{"wood":120, "stone":60}},
	"pickaxe": {"amount":1, "time":5.0, "cost":{"wood":120, "stone":100}},
	"bandage": {"amount":1, "time":2.0, "cost":{"cloth":10}},
	"torch": {"amount":1, "time":2.0, "cost":{"wood":30, "cloth":5}}
}
