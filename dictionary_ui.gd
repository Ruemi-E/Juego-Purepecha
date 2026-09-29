extends CanvasLayer

var panel: Control
var text_display: ItemList
var detail: RichTextLabel
var choices: VBoxContainer
var is_open: bool = false
var was_paused: bool = false
var row_ids: Array[String] = []

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 15
    # La interfaz se comparte también con la escena antigua Dictionary_UI.
    for child in get_children():
        remove_child(child)
        child.queue_free()
    panel = Control.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(panel)
    var shade := ColorRect.new()
    shade.color = Color(0.03, 0.06, 0.04, 0.85)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel.add_child(shade)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel.add_child(center)
    var card := PanelContainer.new()
    card.custom_minimum_size = Vector2(592, 320)
    center.add_child(card)
    var margin := MarginContainer.new()
    for edge in ["left", "top", "right", "bottom"]:
        margin.add_theme_constant_override("margin_" + edge, 12)
    card.add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    margin.add_child(column)
    var heading := Label.new()
    heading.text = "DICCIONARIO · Selecciona una palabra para consultarla"
    heading.add_theme_font_size_override("font_size", 13)
    column.add_child(heading)
    var row := HBoxContainer.new()
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(row)
    text_display = ItemList.new()
    text_display.custom_minimum_size.x = 180
    text_display.add_theme_font_size_override("font_size", 13)
    text_display.item_selected.connect(_select_word)
    row.add_child(text_display)
    var right := VBoxContainer.new()
    right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(right)
    detail = RichTextLabel.new()
    detail.bbcode_enabled = true
    detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail.add_theme_font_size_override("normal_font_size", 12)
    detail.add_theme_font_size_override("bold_font_size", 13)
    right.add_child(detail)
    choices = VBoxContainer.new()
    right.add_child(choices)
    var actions := HBoxContainer.new()
    column.add_child(actions)
    _button(actions, "Volver · J / Esc", toggle_dictionary)
    panel.hide()

func _button(parent: Node, text: String, action: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size.y = 28
    button.add_theme_font_size_override("font_size", 12)
    button.pressed.connect(action)
    parent.add_child(button)
    return button

func _input(event: InputEvent) -> void:
    if is_open and not event.is_echo() and (event.is_action_pressed("open_dictionary") or event.is_action_pressed("ui_cancel")):
        get_viewport().set_input_as_handled()
        toggle_dictionary()

func _unhandled_input(event: InputEvent) -> void:
    if not is_instance_valid(get_tree().get_first_node_in_group("player")) or event.is_echo():
        return
    if event.is_action_pressed("open_dictionary") and not is_open:
        if get_tree().paused and not DialogueManager.is_active:
            return
        get_viewport().set_input_as_handled()
        toggle_dictionary()

func toggle_dictionary() -> void:
    if is_open:
        is_open = false
        panel.hide()
        get_tree().paused = was_paused
        QuestManager.changed.emit()
        GameSession.save_game()
    else:
        was_paused = get_tree().paused
        is_open = true
        get_tree().paused = true
        panel.show()
        refresh_content()
        text_display.grab_focus()

func _clear_choices() -> void:
    for child in choices.get_children():
        choices.remove_child(child)
        child.queue_free()

func refresh_content() -> void:
    _clear_choices()
    text_display.clear()
    row_ids.clear()
    for id in DictionaryManager.Vocabulary.ENTRIES:
        row_ids.append(id)
        var mark := " •" if DictionaryManager.encountered.has(id) else ""
        text_display.add_item(DictionaryManager.word_for(id) + mark)
    for word in DictionaryManager.known_words:
        row_ids.append("legacy:" + str(word))
        text_display.add_item(str(word))
    detail.text = "Las palabras marcadas con • aparecen en tus encargos u objetos.\n\nSelecciona una para ver su significado y orientar tu búsqueda.\n\nVisita la biblioteca al sur del pueblo: Elena te espera con un juego de parejas y premios en monedas.\n\nLas grafías pueden variar entre comunidades; cada término de los encargos incluye su referencia."

func _select_word(index: int) -> void:
    _clear_choices()
    var id := row_ids[index]
    if id.begins_with("legacy:"):
        var word := id.trim_prefix("legacy:")
        detail.text = "[b]" + word + "[/b]\n" + str(DictionaryManager.known_words[word])
        return
    DictionaryManager.consult(id)
    var entry: Dictionary = DictionaryManager.Vocabulary.ENTRIES[id]
    var stats: Dictionary = DictionaryManager.practice.get(id, {"correct": 0, "attempts": 0})
    detail.text = "[b]%s[/b]\n%s\n\n%s\n\nAciertos en biblioteca: %d / %d\n\n%s" % [entry["word"], entry["meaning"], entry["note"], stats["correct"], stats["attempts"], entry["source"]]
