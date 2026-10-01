extends Control

signal closed
var back_button: Button
var volume_slider: HSlider
var fullscreen_toggle: CheckButton

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 300
	center.add_child(panel)
	var margin := MarginContainer.new()
	for edge in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 18)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var title := Label.new()
	title.text = "AJUSTES"
	column.add_child(title)
	var label := Label.new()
	label.text = "Volumen general"
	column.add_child(label)
	volume_slider = HSlider.new()
	volume_slider.max_value = 100
	volume_slider.custom_minimum_size.y = 24
	volume_slider.value_changed.connect(func(value: float): GameSession.set_volume(value / 100.0))
	column.add_child(volume_slider)
	fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.text = "Pantalla completa"
	fullscreen_toggle.toggled.connect(GameSession.set_fullscreen)
	column.add_child(fullscreen_toggle)
	back_button = Button.new()
	back_button.text = "Volver · Esc"
	back_button.custom_minimum_size.y = 38
	back_button.pressed.connect(close)
	column.add_child(back_button)
	hide()

func open() -> void:
	get_child(0).offset_bottom = -52 if is_instance_valid(get_tree().get_first_node_in_group("player")) else 0
	volume_slider.set_value_no_signal(GameSession.volume * 100)
	fullscreen_toggle.set_pressed_no_signal(GameSession.fullscreen)
	show()
	back_button.grab_focus()

func close() -> void:
	hide()
	closed.emit()
