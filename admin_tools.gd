extends CanvasLayer
const UI = preload("res://modal_ui.gd")
const Catalog = preload("res://world_catalog.gd")
var opened := false
var overlay: Control
var was_paused := false
var feedback: Label
var item_choice: OptionButton
var quantity: SpinBox
var coin_amount: SpinBox
var world_choice: OptionButton
var item_ids: Array[String] = []
var world_ids: Array[String] = []
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 40
func available() -> bool:
 return GameSession.active and not GameSession.transitioning and is_instance_valid(get_tree().get_first_node_in_group("player"))
func open_panel() -> void:
 if opened or not available(): return
 # Other dialogs retain ownership of their own pause state.
 if get_tree().paused and not PauseMenu.overlay.visible: return
 opened = true
 was_paused = get_tree().paused
 get_tree().paused = true
 var ui := UI.build(self,"ADMINISTRADOR · PRUEBAS",590)
 overlay = ui.overlay
 UI.label(ui.column,"F10 abre/cierra · Los cambios se guardan en esta partida.",11)
 var scroll := ScrollContainer.new()
 scroll.custom_minimum_size.y = 158
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 ui.column.add_child(scroll)
 var body := VBoxContainer.new()
 body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(body)
 UI.button(body,"Completar todo lo implementado y desbloquear pueblos",func(): complete_all(); report("Misiones y lecciones completadas; pueblos desbloqueados."))
 UI.button(body,"Completar solo la ribera",func(): complete_first(); report("Ribera completada. Puedes viajar a las huertas."))
 var money_row := HBoxContainer.new()
 body.add_child(money_row)
 coin_amount = number(money_row,100,99999)
 UI.button(money_row,"Añadir bronce",func(): add_money(int(coin_amount.value),false))
 UI.button(money_row,"Añadir plata",func(): add_money(int(coin_amount.value),true))
 var items_row := HBoxContainer.new()
 body.add_child(items_row)
 item_choice = OptionButton.new()
 item_choice.custom_minimum_size.x = 250
 item_choice.add_theme_font_size_override("font_size",12)
 item_choice.add_theme_constant_override("icon_max_width",20)
 item_ids.clear()
 for id in Inventory.item_database:
  item_ids.append(str(id))
  item_choice.add_icon_item(preload("res://item_images.gd").icon(id),str(Inventory.item_database[id].name))
 items_row.add_child(item_choice)
 quantity = number(items_row,1,100)
 UI.button(items_row,"Añadir objeto",func(): give_item(item_ids[item_choice.selected],int(quantity.value)))
 UI.button(body,"Añadir uno de cada objeto",give_all_items)
 var travel_row := HBoxContainer.new()
 body.add_child(travel_row)
 world_choice = OptionButton.new()
 world_choice.add_theme_font_size_override("font_size",12)
 world_ids.clear()
 for id in Catalog.TOWNS:
  if Catalog.available(id):
   world_ids.append(str(id))
   world_choice.add_item(str(Catalog.TOWNS[id].name))
 travel_row.add_child(world_choice)
 UI.button(travel_row,"Desbloquear y viajar",func(): travel(world_ids[world_choice.selected]))
 UI.button(body,"Madurar todos los frutales",func():
  OrchardState.harvests.clear()
  OrchardState.commit()
  report("Todos los frutales están maduros."))
 UI.button(body,"Reparar todas las herramientas",func():
  for equipment in Inventory.equipment:
   equipment.durability = int(Inventory.item_database[equipment.item_id].get("max_durability",0))
  GameSession.save_game()
  report("Herramientas reparadas."))
 feedback = UI.label(ui.column,"El encargo final de la tía continúa pendiente: su pueblo aún no está disponible.",10)
 UI.button(ui.column,"Cerrar administrador · F10 / Esc",close_panel).grab_focus()
func number(parent: Node, initial: int, maximum: int) -> SpinBox:
 var box := SpinBox.new()
 box.min_value = 1
 box.max_value = maximum
 box.step = 1
 box.value = initial
 box.custom_minimum_size.x = 76
 box.add_theme_font_size_override("font_size",12)
 parent.add_child(box)
 return box
func report(text: String) -> void:
 if is_instance_valid(feedback): feedback.text = text
func add_money(amount: int, silver: bool) -> void:
 if not available(): return
 amount = clampi(amount,1,99999)
 if silver: Economia.anadir_plata(amount)
 else: Economia.anadir_bronce(amount)
 GameSession.save_game()
 report("Añadidas %d monedas de %s. Consulta el total en I." % [amount,"plata" if silver else "bronce"])
func give_item(id: String, amount: int) -> void:
 if not available() or not Inventory.item_database.has(id): return
 for i in range(clampi(amount,1,100)): Inventory.add_item(id)
 GameSession.save_game()
 report("Añadido: %s × %d" % [Inventory.item_database[id].name,clampi(amount,1,100)])
func give_all_items() -> void:
 if not available(): return
 for id in Inventory.item_database: Inventory.add_item(id)
 GameSession.save_game()
 report("Añadida una unidad de cada objeto.")
func complete_first() -> void:
 if not available(): return
 DictionaryManager.has_dictionary = true
 for item in ["diccionario","morral_recado"]:
  if not Inventory.has_item(item): Inventory.add_item(item)
 for id in ["hierbas","lena","maiz"]: QuestManager.states[id] = "completed"
 QuestManager.states["recado"] = "active"
 QuestManager.tracked_quest = "recado"
 for id in DictionaryManager.Vocabulary.ENTRIES: DictionaryManager.consult(id)
 for id in AdventureState.PUZZLES:
  var data: Dictionary = AdventureState.entry(id)
  data.accepted = true
  data.solved = true
  data.paid = true
  data.values = AdventureState.PUZZLES[id].answer.duplicate()
  if id == "campanas": data.sequence = AdventureState.PUZZLES[id].answer.duplicate()
  if id == "faroles": data.hint_unlocked = true
 GameSession.tutorial_step = 6
 QuestManager.changed.emit()
 AdventureState.changed.emit()
 GameSession.save_game()
func complete_all() -> void:
 if not available(): return
 complete_first()
 OrchardState.stage = 4
 OrchardState.recognition = 2
 OrchardState.recall = 3
 OrchardState.order = 2
 OrchardState.picked["aguacate"] = maxi(2,int(OrchardState.picked.get("aguacate",0)))
 OrchardState.picked["durazno"] = maxi(3,int(OrchardState.picked.get("durazno",0)))
 for id in Catalog.TOWNS:
  if Catalog.available(id) and not id in GameSession.visited: GameSession.visited.append(id)
 OrchardState.commit()
 QuestJournal.refresh()
func travel(id: String) -> void:
 if not available() or not Catalog.available(id): return
 if id == GameSession.current_world_id:
  report("Ya estás en ese pueblo.")
  return
 if not id in GameSession.visited: GameSession.visited.append(id)
 close_panel()
 PauseMenu.resume_game()
 GameSession.travel_to(id)
func close_panel() -> void:
 if not opened: return
 opened = false
 overlay.queue_free()
 get_tree().paused = was_paused
 GameSession.save_game()
func _input(event: InputEvent) -> void:
 if event.is_echo(): return
 if event is InputEventKey and event.pressed and (event.physical_keycode == KEY_F10 or event.keycode == KEY_F10):
  get_viewport().set_input_as_handled()
  if opened: close_panel()
  else: open_panel()
 elif opened and event.is_action_pressed("ui_cancel"):
  get_viewport().set_input_as_handled()
  close_panel()
