extends Node

signal item_added(item_id: String, item_data: Dictionary)
signal item_removed(item_id: String)

# Base de datos global de objetos del juego
var item_database: Dictionary = {
 "remedio_sencillo": {"name": "Remedio sencillo", "purepecha": "Remedio sencillo", "desc": "Objeto del botiquín del juego. Su uso se habilitará cuando se añada el sistema de salud.", "shop": "remedies", "price": 4},
 "unguento": {"name": "Ungüento", "purepecha": "Ungüento", "desc": "Objeto del botiquín del juego. Su uso se habilitará cuando se añada el sistema de salud.", "shop": "remedies", "price": 6},
 "hierbas_medicinales": {"name": "Hierbas medicinales", "purepecha": "uitsakua", "desc": "Entrega tres a Teresa, junto a la casa de adobe pequeña."},
 "lena_seca": {"name": "Leña seca", "purepecha": "chkári", "desc": "Mateo necesita tres haces para el taller del sur."},
 "mazorca": {"name": "Mazorca", "purepecha": "xanini", "desc": "Rosa espera cuatro mazorcas junto a la casa de adobe al oeste de la plaza."},
 "diccionario": {
  "name": "Diccionario Purépecha",
  "purepecha": "Diccionario",
  "desc": "Cuaderno con palabras de los abuelos."
 },
 "itsï": {
  "name": "Agua fresca",
  "shop": "food", "price": 1,
  "purepecha": "Itsï",
  "desc": "Agua limpia del manantial."
 },
 "kurhinda": {
  "name": "Pan tradicional",
  "shop": "food", "price": 2,
  "purepecha": "Kurhinda",
  "desc": "Pan horneado en leña."
 },
 "morral_recado": {
  "name": "Morral con encargo",
  "purepecha": "sutupu",
  "desc": "Entrego importante para la tía."
 }
}

# Lista de IDs que el jugador tiene en su morral
var items: Array[String] = []

func add_item(item_id: String) -> void:
 items.append(item_id)
 var maximum: int = int(item_database.get(item_id, {}).get("max_durability", 0))
 if maximum > 0:
  equipment.append({"uid": next_equipment_uid, "item_id": item_id, "durability": maximum})
  next_equipment_uid += 1
 if DictionaryManager.Vocabulary.ENTRIES.has(item_id):
  DictionaryManager.encountered[item_id] = true
 var data = item_database.get(item_id, {"name": item_id, "purepecha": item_id, "desc": ""})
 item_added.emit(item_id, data)
 


func remove_item(item_id: String) -> bool:
 if has_item(item_id):
  items.erase(item_id)
  for index in range(equipment.size()):
   if equipment[index]["item_id"] == item_id:
    equipment.remove_at(index)
   break
  item_removed.emit(item_id)
  return true
 return false

func has_item(item_id: String) -> bool:
 return item_id in items

# Cada herramienta futura conserva su propio estado, incluso si hay duplicados.
var equipment: Array[Dictionary] = []
var next_equipment_uid: int = 1

func damage_equipment(uid: int, amount: int) -> void:
 for entry in equipment:
  if entry["uid"] == uid:
   entry["durability"] = maxi(0, int(entry["durability"]) - maxi(0, amount))
   return

func restore_equipment(saved: Array) -> void:
 equipment.clear()
 next_equipment_uid = 1
 var restored_counts: Dictionary = {}
 for value in saved:
  if not value is Dictionary:
   continue
  var id: String = str(value.get("item_id", ""))
  var data: Dictionary = item_database.get(id, {})
  var maximum: int = int(data.get("max_durability", 0))
  if maximum <= 0 or int(restored_counts.get(id, 0)) >= items.count(id):
   continue
  equipment.append({"uid": next_equipment_uid, "item_id": id, "durability": clampi(int(value.get("durability", maximum)), 0, maximum)})
  next_equipment_uid += 1
  restored_counts[id] = int(restored_counts.get(id, 0)) + 1
 # Compatible con partidas que tenían herramientas sin estado individual.
 for id in items:
  var maximum: int = int(item_database.get(id, {}).get("max_durability", 0))
  if maximum > 0:
   if int(restored_counts.get(id, 0)) > 0:
    restored_counts[id] -= 1
   else:
    equipment.append({"uid": next_equipment_uid, "item_id": id, "durability": maximum})
    next_equipment_uid += 1
