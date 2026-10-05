extends CanvasLayer

var overlay: Control
var menu: CenterContainer
var settings: Control
var resume_button: Button
var settings_button: Button

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 20
    overlay = Control.new()
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(overlay)
    var shade := ColorRect.new()
    shade.color = Color(0.02, 0.04, 0.03, 0.75)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(shade)
    menu = CenterContainer.new()
    menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(menu)
    var panel := PanelContainer.new()
    panel.custom_minimum_size.x = 260
    menu.add_child(panel)
    var margin := MarginContainer.new()
    for edge in ["left", "top", "right", "bottom"]:
        margin.add_theme_constant_override("margin_" + edge, 18)
    panel.add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    margin.add_child(column)
    var title := Label.new()
    title.text = "PAUSA"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    column.add_child(title)
    resume_button = _button(column, "Continuar · Esc", resume_game)
    _button(column, "Mundos", ExplorationUI.open_worlds)
    settings_button = _button(column, "Ajustes", show_settings)
    _button(column, "Ayuda", GameHelp.open_help)
    _button(column, "Salir del juego", exit_game)
    settings = preload("res://settings_panel.gd").new()
    overlay.add_child(settings)
    settings.closed.connect(func():
        menu.show()
        settings_button.grab_focus())
    overlay.hide()

func _button(parent: Control, text: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size.y = 30
    button.pressed.connect(callback)
    parent.add_child(button)
    return button

func _unhandled_input(event: InputEvent) -> void:
    if event.is_echo() or not event.is_action_pressed("ui_cancel"):
        return
    if not overlay.visible and not get_tree().paused and is_instance_valid(get_tree().get_first_node_in_group("player")):
        get_viewport().set_input_as_handled()
        open_pause()

func _input(event: InputEvent) -> void:
    if ExplorationUI.opened or GameHelp.opened or LanternHelp.opened:
        return
    if overlay.visible and not event.is_echo() and event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        if settings.visible:
            settings.close()
        else:
            resume_game()

func open_pause() -> void:
    get_tree().paused = true
    overlay.show()
    settings.hide()
    menu.show()
    resume_button.grab_focus()

func show_settings() -> void:
    menu.hide()
    settings.open()

func resume_game() -> void:
    overlay.hide()
    get_tree().paused = false

func exit_game() -> void:
    GameSession.save_game()
    get_tree().quit()
