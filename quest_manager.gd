extends Node

signal changed

const QUESTS: Dictionary = {
 "hierbas": {"speaker": "Teresa · Curandera", "title": "El encargo de Teresa", "item": "hierbas_medicinales", "amount": 3, "bronze": 6, "silver": 0, "request": "Necesito reunir: [b]uitsakua[/b] × 3. Consulta la palabra con J; después cruza el puente y busca junto al sendero. Recoge con E y vuelve conmigo."},
 "lena": {"speaker": "Mateo · Carpintero", "title": "El encargo de Mateo", "item": "lena_seca", "amount": 3, "bronze": 0, "silver": 1, "request": "Necesito reunir: [b]chkári[/b] × 3. Consulta la palabra con J; después busca al este del pueblo, cerca de los árboles. Recoge con E y vuelve conmigo."},
 "maiz": {"speaker": "Rosa · Agricultora", "title": "El encargo de Rosa", "item": "mazorca", "amount": 4, "bronze": 8, "silver": 0, "request": "Necesito reunir: [b]xanini[/b] × 4. Consulta la palabra con J; después busca en mi patio, al oeste de la plaza. Recoge con E y vuelve conmigo."},
 "recado": {"speaker": "Tía Juana", "title": "El viaje a casa de tu tía", "item": "morral_recado", "amount": 1, "bronze": 0, "silver": 2, "request": "Conserva el [b]sutupu[/b] de Tátita durante el viaje. Ayuda a los vecinos y consulta la ruta con Amalia, en la salida del este. Tu tía espera en un pueblo posterior."}
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
 if id == "recado":
  return "Tu tía te espera al final del viaje. Conserva el sutupu y consulta la ruta con Amalia en la salida del este."
 var q: Dictionary = QUESTS[id]
 DictionaryManager.encountered[q["item"]] = true
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
 return heading + "¡Gracias! Recibí el encargo completo. Practica esta palabra en la biblioteca al sur del pueblo.\n[color=green]Recompensa: %s[/color]\nPulsa I para consultar tus monedas." % reward_text(id)


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
