extends Node

signal item_added(item_id: String, item_data: Dictionary)
signal item_removed(item_id: String)

# Base de datos global de objetos del juego
var item_database: Dictionary = {
 "hierbas_medicinales": {"name": "Hierbas medicinales", "purepecha": "Hierbas medicinales", "desc": "Entrega tres a Teresa, junto a la casa de adobe pequeña."},
 "lena_seca": {"name": "Leña seca", "purepecha": "Leña seca", "desc": "Mateo necesita tres haces para el taller del sur."},
 "mazorca": {"name": "Mazorca", "purepecha": "Mazorca", "desc": "Rosa espera cuatro mazorcas junto a la casa de adobe al oeste de la plaza."},
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
  item_removed.emit(item_id)
  return true
 return false

func has_item(item_id: String) -> bool:
 return item_id in items
