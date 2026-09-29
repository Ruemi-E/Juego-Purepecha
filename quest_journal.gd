extends CanvasLayer

var panel: PanelContainer
var content: RichTextLabel
var hint: Label
var opened: bool = false

func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 layer = 8
 hint = Label.new()
 hint.position = Vector2(172, 8)
 hint.add_theme_font_size_override("font_size", 9)
 hint.add_theme_color_override("font_shadow_color", Color.BLACK)
 hint.add_theme_constant_override("shadow_offset_x", 1)
 hint.add_theme_constant_override("shadow_offset_y", 1)
 hint.text = "E · Hablar / recoger    M · Misiones    I · Inventario"
 add_child(hint)
 panel = PanelContainer.new()
 panel.position = Vector2(50, 35)
 panel.size = Vector2(540, 290)
 add_child(panel)
 var margin = MarginContainer.new()
 for edge in ["left", "right", "top", "bottom"]:
  margin.add_theme_constant_override("margin_" + edge, 12)
 panel.add_child(margin)
 content = RichTextLabel.new()
 content.bbcode_enabled = true
 content.add_theme_font_size_override("normal_font_size", 12)
 content.add_theme_font_size_override("bold_font_size", 12)
 margin.add_child(content)
 panel.hide()
 QuestManager.changed.connect(refresh)

func _process(_delta: float) -> void:
 hint.visible = not get_tree().paused

func _unhandled_input(event: InputEvent) -> void:
 if event.is_echo():
  return
 if opened and (event.is_action_pressed("open_quests") or event.is_action_pressed("ui_cancel")):
  opened = false
  panel.hide()
  get_tree().paused = false
  get_viewport().set_input_as_handled()
 elif not get_tree().paused and event.is_action_pressed("open_quests"):
  opened = true
  refresh()
  panel.show()
  get_tree().paused = true
  get_viewport().set_input_as_handled()

func refresh() -> void:
 if not is_instance_valid(content):
  return
 var text := "[b]MISIONES DEL PUEBLO[/b]    [M / Esc] Cerrar\n\n"
 for id in QuestManager.QUESTS:
  var q: Dictionary = QuestManager.QUESTS[id]
  var state: String = QuestManager.status(id)
  var label := "Habla con " + str(q["speaker"])
  if state == "active":
   var count: int = mini(QuestManager.progress(id), q["amount"])
   label = "%s: %d/%d" % [Inventory.item_database[q["item"]]["name"], count, q["amount"]]
   if count == q["amount"]:
    label += " · Vuelve para entregar"
  elif state == "completed":
   label = "[color=light_green]Completada · Recompensa recibida[/color]"
  text += "[b]%s[/b] · %s\n%s\n\n" % [q["title"], QuestManager.reward_text(id), label]
 content.text = text
