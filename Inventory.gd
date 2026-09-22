extends Node

signal item_added(item_id: String, item_data: Dictionary)

# Base de datos global de objetos del juego
var item_database: Dictionary = {
	"diccionario": {
		"name": "Diccionario Purépecha",
		"purepecha": "Anhatapu Karáni",
		"desc": "Cuaderno con palabras de los abuelos."
	},
	"itsï": {
		"name": "Agua fresca",
		"purepecha": "Itsï",
		"desc": "Agua limpia del manantial."
	},
	"kurhinda": {
		"name": "Pan tradicional",
		"purepecha": "Kurhinda",
		"desc": "Pan horneado en leña."
	},
	"morral_recado": {
		"name": "Morral con encargo",
		"purepecha": "Morrali",
		"desc": "Entrego importante para la tía."
	}
}

# Lista de IDs que el jugador tiene en su morral
var items: Array[String] = []

func add_item(item_id: String) -> void:
	items.append(item_id)
	var data = item_database.get(item_id, {"name": item_id, "purepecha": item_id, "desc": ""})
	item_added.emit(item_id, data)
	


func remove_item(item_id: String) -> bool:
	if has_item(item_id):
		items.erase(item_id)
		return true
	return false

func has_item(item_id: String) -> bool:
	return item_id in items
