extends CanvasLayer
const UI = preload("res://modal_ui.gd")
const COST := 3
const THRESHOLD := 12
var opened := false
var overlay: Control
var column: VBoxContainer
var notice: Label
var was_paused := false
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 29
func eligible() -> bool:
 var data: Dictionary = AdventureState.entry("faroles")
 return data.accepted and not data.solved and int(data.get("attempts",0)) >= THRESHOLD
func offer() -> void:
 if opened or not eligible():
  return
 opened = true
 was_paused = get_tree().paused
 get_tree().paused = true
 var ui := UI.build(self,"BETO · UNA PISTA PARA LOS FAROLES")
 overlay = ui.overlay
 column = ui.column
 if AdventureState.entry("faroles").get("hint_unlocked",false):
  _show_hint()
 else:
  UI.label(column,"Llevas %d movimientos sin resolverlo. Por 3 monedas de bronce puedo darte pistas en purépecha. El pago desbloquea todas las pistas de este acertijo." % int(AdventureState.entry("faroles").get("attempts",0)))
  UI.button(column,"Desbloquear pistas · 3 bronces",purchase)
  notice = UI.label(column,"",11)
 UI.button(column,"Seguir intentando · Esc",close).grab_focus()
func purchase() -> void:
 var data: Dictionary = AdventureState.entry("faroles")
 if data.get("hint_unlocked",false):
  return
 if not Economia.gastar_bronce(COST):
  notice.text = "No tienes suficientes monedas de bronce. Puedes volver a hablar conmigo más tarde."
  return
 data["hint_unlocked"] = true
 DictionaryManager.unlock_word("jurhijkandani","Derecha. Pista de los faroles.")
 DictionaryManager.unlock_word("uikixkandani","Izquierda. Pista de los faroles.")
 GameSession.save_game()
 close()
 offer()
func solution(values: Array) -> Array[int]:
 var best: Array[int] = []
 var best_size := 6
 for mask in range(32):
  var state: Array = values.duplicate()
  var presses: Array[int] = []
  for i in range(4,-1,-1):
   if mask & (1 << i):
    presses.append(i)
    for j in [i,(i+1)%5,(i+4)%5]:
     state[j] = 1-int(state[j])
  if state == [1,1,1,1,1] and presses.size() < best_size:
   best = presses
   best_size = presses.size()
 return best
func hint_text() -> String:
 var presses := solution(AdventureState.entry("faroles").values)
 if presses.is_empty():
  return "¡Ya están encendidos! Vuelve por tu recompensa."
 var positions := ["uikixkandani: el extremo (1)","uikixkandani: el segundo desde ese lado (2)","entre uikixkandani y jurhijkandani: el centro (3)","jurhijkandani: el segundo desde ese lado (4)","jurhijkandani: el extremo (5)"]
 return "Activa el farol ubicado en %s. Después vuelve conmigo para la siguiente pista.\n\nLos faroles se numeran del 1 al 5 de izquierda a derecha. Cada palanca invierte tres luces, aunque alguna se apague por el camino." % positions[presses[0]]
func _show_hint() -> void:
 UI.label(column,hint_text())
 UI.label(column,"jurhijkandani = derecha · uikixkandani = izquierda\nEstas palabras también se añaden a tu diccionario. Las próximas pistas son gratis.",11)
func close() -> void:
 if not opened:
  return
 opened = false
 overlay.queue_free()
 get_tree().paused = was_paused
func _input(event: InputEvent) -> void:
 if opened and event.is_action_pressed("ui_cancel") and not event.is_echo():
  get_viewport().set_input_as_handled()
  close()
