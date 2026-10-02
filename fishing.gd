extends CanvasLayer
const UI = preload("res://modal_ui.gd")
var opened := false
var overlay: Control
var text: Label
var action_button: Button
var meter: Control
var phase := "ready"
var timer := 0.0
var cursor_time := 0.0
var hits := 0
var misses := 0
var rng := RandomNumberGenerator.new()
func _ready() -> void:
 layer = 23
 process_mode = Node.PROCESS_MODE_ALWAYS
 rng.randomize()
func open_fishing() -> void:
 if opened or get_tree().paused:
  return
 opened = true
 get_tree().paused = true
 var ui := UI.build(self,"PESCA · LAGO DE PÁTZCUARO")
 overlay = ui.overlay
 text = UI.label(ui.column,"Equipa una caña en la barra rápida. Cada intento consume un anzuelo\ny 1 punto de durabilidad. Espacio: lanzar, enganchar y recoger.")
 text.custom_minimum_size.y = 62
 meter = preload("res://fishing_meter.gd").new()
 meter.custom_minimum_size = Vector2(510,34)
 ui.column.add_child(meter)
 action_button = UI.button(ui.column,"Lanzar · Espacio",act)
 UI.button(ui.column,"Salir · Esc (el anzuelo usado no se recupera)",close_fishing)
 phase = "ready"
func cast() -> bool:
 var rod: Dictionary = Inventory.active_equipment()
 if rod.is_empty() or not Inventory.item_database[rod.item_id].get("fishing_rod",false):
  text.text = "Selecciona una caña en 1–5 antes de empezar. Tomás vende cañas."
  return false
 if rod.durability <= 0:
  text.text = "La caña está rota. Llévala a reparar con Tomás."
  return false
 if not Inventory.remove_item("anzuelo"):
  text.text = "Necesitas un anzuelo. Lucía los vende en la tienda de comida."
  return false
 Inventory.damage_equipment(rod.uid,1)
 phase = "waiting"
 timer = rng.randf_range(1.4,3.2)
 hits = 0
 misses = 0
 text.text = "El anzuelo está en el agua… Espera a que pique."
 action_button.text = "Esperando…"
 GameSession.save_game()
 return true
func act() -> void:
 if phase in ["ready","result"]:
  cast()
 elif phase == "waiting":
  finish(false,"Tiraste demasiado pronto. El pez escapó.")
 elif phase == "bite":
  phase = "reeling"
  cursor_time = 0
  action_button.text = "Recoger · Espacio"
  text.text = "¡Picó! Detén la marca en la zona verde tres veces."
 elif phase == "reeling":
  if meter.cursor >= 0.35 and meter.cursor <= 0.65:
   hits += 1
  else:
   misses += 1
  if hits >= 3:
   finish(true,"")
  elif misses >= 2:
   finish(false,"La tensión fue demasiada. El pez escapó.")
  else:
   cursor_time += 0.7
   text.text = "Aciertos %d/3 · Fallos %d/2 · Espacio en verde" % [hits,misses]
func finish(caught: bool, reason: String) -> void:
 # A resolved cast cannot pay twice, even if input repeats in the same frame.
 if phase == "result":
  return
 phase = "result"
 if caught:
  var id: String = ["charal","mojarra","carpa"][rng.randi_range(0,2)]
  Inventory.add_item(id)
  text.text = "¡Capturaste %s! Lucía lo compra por %d bronce.\nPuedes lanzar de nuevo si te quedan anzuelos." % [Inventory.item_database[id].name,Inventory.item_database[id].sell_price]
 else:
  text.text = reason + " Puedes volver a intentarlo."
 action_button.text = "Volver a lanzar · Espacio"
 GameSession.save_game()
func _process(delta: float) -> void:
 if not opened:
  return
 if phase in ["waiting","bite"]:
  timer -= delta
  if timer <= 0:
   if phase == "waiting":
    phase = "bite"
    timer = 1.6
    text.text = "¡PICÓ! Pulsa Espacio o el botón para enganchar."
    action_button.text = "¡Enganchar! · Espacio"
   else:
    finish(false,"Se fue el pez. Engancha en cuanto pique.")
 elif phase == "reeling":
  cursor_time += delta
  meter.cursor = (sin(cursor_time*3.8)+1.0)*0.5
  meter.queue_redraw()
func close_fishing() -> void:
 opened = false
 overlay.queue_free()
 get_tree().paused = false
 GameSession.save_game()
func _input(event: InputEvent) -> void:
 if not opened or event.is_echo():
  return
 if event.is_action_pressed("ui_cancel"):
  get_viewport().set_input_as_handled()
  close_fishing()
 elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_SPACE:
  get_viewport().set_input_as_handled()
  act()
