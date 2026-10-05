extends CanvasLayer
var card: PanelContainer
var text: Label
const STEPS := [
 "WASD o flechas: camina hacia el abuelo Tátita, junto a la casa inicial.",
 "Pulsa E cerca de Tátita para hablar. Usa E para avanzar el diálogo y recibir tu diccionario.",
 "Pulsa J para abrir el diccionario. Consulta las palabras de tus encargos para orientarte; ciérralo con Esc.",
 "Pulsa Tab para ver el mapa. Haz clic para fijar una ruta; clic derecho la borra. Tab o Esc para volver.",
 "Pulsa I para ver tus objetos y monedas. Los objetos iguales se agrupan; 1–5 seleccionan los accesos rápidos.",
 "Pulsa M para revisar tus misiones. Q cambia el encargo seguido. Encontrarás todos los controles en Esc → Ayuda."
]
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 9
 card = PanelContainer.new()
 card.position = Vector2(192,222)
 card.custom_minimum_size = Vector2(420,0)
 var style := StyleBoxFlat.new()
 style.bg_color = Color("233a35",0.96)
 style.set_content_margin_all(8)
 style.border_color = Color("d0b77b")
 style.set_border_width_all(1)
 card.add_theme_stylebox_override("panel",style)
 add_child(card)
 var column := VBoxContainer.new()
 card.add_child(column)
 text = Label.new()
 text.custom_minimum_size.x = 398
 text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 text.add_theme_font_size_override("font_size",11)
 column.add_child(text)
 var skip := Button.new()
 skip.text = "Omitir tutorial"
 skip.add_theme_font_size_override("font_size",9)
 skip.pressed.connect(func(): GameSession.tutorial_step = 6; GameSession.save_game())
 column.add_child(skip)
 card.hide()
func _process(_delta: float) -> void:
 var player := get_tree().get_first_node_in_group("player") as Node2D
 var step: int = GameSession.tutorial_step
 card.visible = GameSession.active and is_instance_valid(player) and step < 6 and not get_tree().paused
 if not GameSession.active or not is_instance_valid(player) or step >= 6:
  return
 text.text = "PRIMEROS PASOS · %d/6\n%s" % [step+1,STEPS[step]]
 var done := false
 match step:
  0:
   var grandpa := get_tree().current_scene.get_node_or_null("NPC") as Node2D
   done = is_instance_valid(grandpa) and player.global_position.distance_to(grandpa.global_position) <= 60
  1: done = DictionaryManager.has_dictionary
  2: done = DictionaryUi.is_open
  3: done = ExplorationUI.opened and ExplorationUI.map_mode
  4: done = InventoryUi.is_open
  5: done = QuestJournal.opened
 if done:
  GameSession.tutorial_step += 1
  GameSession.save_game()
