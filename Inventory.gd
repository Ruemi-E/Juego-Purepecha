extends Node

var items: Array[String] = []

func add_item(item_id: String) -> void:
	items.append(item_id)
	print("Guardado en morral: ", item_id)

func remove_item(item_id: String) -> bool:
	if has_item(item_id):
		items.erase(item_id)
		return true
	return false

func has_item(item_id: String) -> bool:
	return item_id in items
