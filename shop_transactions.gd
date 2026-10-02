extends RefCounted

static func products(shop: String) -> Array[String]:
	var result: Array[String] = []
	for id in Inventory.item_database:
		if Inventory.item_database[id].get("shop", "") == shop:
			result.append(id)
	return result

static func purchase(shop: String, item_id: String) -> String:
	if not item_id in products(shop):
		return "Este objeto no está a la venta aquí."
	var data: Dictionary = Inventory.item_database[item_id]
	var price: int = int(data.get("price", 0))
	if price <= 0:
		return "Este objeto todavía no tiene precio."
	if not Economia.gastar_bronce(price):
		return "No tienes monedas suficientes. Puedes ganar más en la biblioteca."
	Inventory.add_item(item_id)
	GameSession.save_game()
	return "Compraste: %s · −%d bronce" % [data.get("purepecha", data["name"]), price]

static func repair_cost(equipment: Dictionary) -> int:
	var data: Dictionary = Inventory.item_database.get(equipment.get("item_id", ""), {})
	var maximum: int = int(data.get("max_durability", 0))
	if maximum <= 0 or not data.get("repairable", false):
		return 0
	return maxi(0, maximum - int(equipment.get("durability", maximum))) * maxi(1, int(data.get("repair_price_per_point", 1)))

static func repair(uid: int) -> String:
	for equipment in Inventory.equipment:
		if equipment["uid"] != uid:
			continue
		var cost: int = repair_cost(equipment)
		if cost <= 0:
			return "Este objeto no necesita reparación o no es reparable."
		if not Economia.gastar_bronce(cost):
			return "No tienes monedas suficientes para esta reparación."
		equipment["durability"] = int(Inventory.item_database[equipment["item_id"]]["max_durability"])
		GameSession.save_game()
		return "Objeto reparado · −%d bronce" % cost
	return "Ya no tienes ese objeto."

const RECIPES: Dictionary = {
	"pico_hierro": {"materials": {"mineral_hierro": 6, "piedra": 4, "carbon": 2}, "price": 4},
	"hacha_hierro": {"materials": {"mineral_hierro": 4, "piedra": 2, "carbon": 2}, "price": 3},
	"martillo_hierro": {"materials": {"mineral_hierro": 4, "piedra": 4, "carbon": 2}, "price": 3}
}

static func can_craft(id: String) -> bool:
	if not RECIPES.has(id):
		return false
	var recipe: Dictionary = RECIPES[id]
	if Economia.total_bronce() < int(recipe["price"]):
		return false
	for material in recipe["materials"]:
		if Inventory.items.count(material) < int(recipe["materials"][material]):
			return false
	return true

static func craft(id: String) -> String:
	if not can_craft(id):
		return "Faltan materiales o monedas. No se ha consumido nada."
	var recipe: Dictionary = RECIPES[id]
	if not Economia.gastar_bronce(int(recipe["price"])):
		return "No tienes suficientes monedas."
	for material in recipe["materials"]:
		for i in range(int(recipe["materials"][material])):
			Inventory.remove_item(material)
	Inventory.add_item(id)
	GameSession.save_game()
	return "Tomás fabricó: " + str(Inventory.item_database[id]["name"])

static func sell_fish(id: String) -> String:
	var data: Dictionary = Inventory.item_database.get(id,{})
	var price: int = int(data.get("sell_price",0))
	if price <= 0 or not Inventory.remove_item(id):
		return "No tienes ese pescado para vender."
	Economia.anadir_bronce(price)
	GameSession.save_game()
	return "Vendiste %s por %d bronce." % [data.name,price]
