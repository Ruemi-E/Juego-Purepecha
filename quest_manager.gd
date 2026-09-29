extends Node

signal changed

const QUESTS: Dictionary = {
 "hierbas": {"speaker": "Teresa · Curandera", "title": "Hierbas de la otra orilla", "item": "hierbas_medicinales", "amount": 3, "bronze": 6, "silver": 0, "request": "Necesito 3 hierbas medicinales. Cruza el puente y búscalas junto al sendero de la otra orilla. Recógelas con E y vuelve conmigo."},
 "lena": {"speaker": "Mateo · Carpintero", "title": "Madera para el taller", "item": "lena_seca", "amount": 3, "bronze": 0, "silver": 1, "request": "Necesito 3 haces de leña seca para el taller. Están al este del pueblo, cerca de los árboles. Recógelos con E y tráemelos."},
 "maiz": {"speaker": "Rosa · Agricultora", "title": "La cosecha del patio", "item": "mazorca", "amount": 4, "bronze": 8, "silver": 0, "request": "Ayúdame a reunir 4 mazorcas de mi huerto, al oeste de la plaza. Recógelas con E y vuelve para entregar la cosecha."},
 "recado": {"speaker": "Tía Juana", "title": "El encargo de Tátita", "item": "morral_recado", "amount": 1, "bronze": 0, "silver": 2, "request": "Tátita tiene un morral para mí. Habla con él junto a la casa del inicio y tráeme su encargo. Si ya lo tienes, vuelve a hablar conmigo para entregarlo."}
}
var states: Dictionary = {}
var tracked_quest: String = ""

func _ready() -> void:
 Inventory.item_added.connect(_on_item_added)
 Inventory.item_removed.connect(_on_item_removed)

func _on_item_added(_id: String, _data: Dictionary) -> void:
 changed.emit()

func _on_item_removed(_id: String) -> void:
 changed.emit()

func status(id: String) -> String:
 return states.get(id, "available")

func progress(id: String) -> int:
 return Inventory.items.count(QUESTS[id]["item"])

func reward_text(id: String) -> String:
 var q: Dictionary = QUESTS[id]
 if q["silver"] > 0:
  return "%d moneda(s) de plata" % q["silver"]
 return "%d moneda(s) de bronce" % q["bronze"]

func talk(id: String) -> String:
 if not QUESTS.has(id):
  return "Este encargo no está disponible."
 var q: Dictionary = QUESTS[id]
 var heading: String = "[color=yellow]%s[/color]\n" % q["speaker"]
 if status(id) == "completed":
  return heading + "Gracias por tu ayuda. Ya te entregué la recompensa de este encargo."
 if status(id) == "available":
  states[id] = "active"
  tracked_quest = id
  changed.emit()
  return heading + q["request"] + "\n[color=green]Misión aceptada · Recompensa: %s[/color]\n[M] Consulta tus misiones." % reward_text(id)
 var amount: int = q["amount"]
 if progress(id) < amount:
  return heading + "Todavía faltan objetos (%d/%d).\n" % [progress(id), amount] + q["request"]
 # Mark complete before emitting inventory events or paying; repeated interactions never pay twice.
 states[id] = "completed"
 for i in range(amount):
  Inventory.remove_item(q["item"])
 Economia.anadir_bronce(q["bronze"])
 Economia.anadir_plata(q["silver"])
 changed.emit()
 return heading + "¡Gracias! Recibí el encargo completo.\n[color=green]Recompensa: %s[/color]\nPulsa I para consultar tus monedas." % reward_text(id)


func tracked_id() -> String:
 if not tracked_quest.is_empty() and status(tracked_quest) == "active":
  return tracked_quest
 for id in QUESTS:
  if status(id) == "active":
   tracked_quest = id
   return id
 tracked_quest = ""
 return ""

func cycle_tracked() -> void:
 var active: Array[String] = []
 for id in QUESTS:
  if status(id) == "active":
   active.append(id)
 if active.is_empty():
  tracked_quest = ""
  return
 var index: int = active.find(tracked_id())
 tracked_quest = active[(index + 1) % active.size()]
 changed.emit()
