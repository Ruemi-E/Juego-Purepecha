extends CanvasLayer
const Catalog = preload("res://world_catalog.gd")
var overlay: Control
var status_label: Label
var travel_button: Button
var opened := false

func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 19
 QuestManager.changed.connect(_refresh)

func requirements_met() -> bool:
 for id in Catalog.TOWNS[GameSession.current_world_id]["quests"]:
  if QuestManager.status(id) != "completed":
   return false
 return DictionaryManager.has_dictionary and Inventory.has_item("morral_recado")

func next_id() -> String:
 return str(Catalog.TOWNS[GameSession.current_world_id]["next"])

func can_travel(id: String) -> bool:
 return id == next_id() and requirements_met() and Catalog.available(id)

func open_route(_player: CharacterBody2D = null) -> void:
 if opened or get_tree().paused:
  return
 opened = true
 get_tree().paused = true
 overlay = Control.new()
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(overlay)
 var shade := ColorRect.new()
 shade.color = Color(0.03, 0.06, 0.05, 0.9)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.add_child(shade)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 center.offset_bottom = -52
 overlay.add_child(center)
 var panel := PanelContainer.new()
 panel.custom_minimum_size = Vector2(560, 276)
 center.add_child(panel)
 var margin := MarginContainer.new()
 for edge in ["left", "right", "top", "bottom"]:
  margin.add_theme_constant_override("margin_" + edge, 14)
 panel.add_child(margin)
 var column := VBoxContainer.new()
 column.add_theme_constant_override("separation", 8)
 margin.add_child(column)
 var title := Label.new()
 title.text = "EL VIAJE · RUMBO A CASA DE TU TÍA"
 title.add_theme_font_size_override("font_size", 18)
 column.add_child(title)
 status_label = Label.new()
 status_label.add_theme_font_size_override("font_size", 12)
 status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 status_label.custom_minimum_size.x = 520
 status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
 column.add_child(status_label)
 travel_button = Button.new()
 travel_button.custom_minimum_size.y = 32
 travel_button.pressed.connect(func(): travel_to(next_id()))
 column.add_child(travel_button)
 var close := Button.new()
 close.text = "Volver al pueblo · Esc"
 close.custom_minimum_size.y = 32
 close.pressed.connect(close_route)
 column.add_child(close)
 _refresh()
 close.grab_focus()

func _refresh() -> void:
 if not opened or not is_instance_valid(status_label):
  return
 var lines: Array[String] = ["1 · Pueblo de la ribera — estás aquí"]
 for id in Catalog.TOWNS[GameSession.current_world_id]["quests"]:
  lines.append("   %s %s" % ["✓" if QuestManager.status(id) == "completed" else "○", QuestManager.QUESTS[id]["title"]])
 lines.append("   %s Llevar el sutupu de Tátita" % ["✓" if Inventory.has_item("morral_recado") else "○"])
 lines.append("2 · Siguiente pueblo — disponible en una futura actualización")
 lines.append("Destino final · Entregar el encargo a tu tía al terminar el viaje")
 lines.append("\n¡Primer pueblo completado! Conserva el encargo; puedes seguir explorando." if requirements_met() else "\nAyuda a Teresa, Mateo y Rosa y habla con Tátita para preparar tu viaje.")
 status_label.text = "\n".join(lines)
 travel_button.disabled = not can_travel(next_id())
 travel_button.text = "Viajar al siguiente pueblo" if can_travel(next_id()) else ("Ruta preparada · Próximo pueblo en desarrollo" if requirements_met() else "Ruta bloqueada · Completa los encargos")

func travel_to(id: String) -> bool:
 if not can_travel(id):
  return false
 close_route()
 return GameSession.travel_to(id)

func close_route() -> void:
 if not opened:
  return
 opened = false
 overlay.queue_free()
 get_tree().paused = false
 GameSession.save_game()

func _input(event: InputEvent) -> void:
 if opened and event.is_action_pressed("ui_cancel") and not event.is_echo():
  get_viewport().set_input_as_handled()
  close_route()
