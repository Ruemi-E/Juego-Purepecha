extends Control

## Asigna aquí la imagen de fondo desde el Inspector de MainMenu.tscn.
@export var background_image: Texture2D
var load_button: Button
var status_label: Label
var settings: Control
var buttons: VBoxContainer

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("182c2a")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var image := TextureRect.new()
	image.name = "BackgroundImage"
	image.texture = background_image
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(image)
	var shade := ColorRect.new()
	shade.color = Color(0.03, 0.08, 0.07, 0.48)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	buttons = VBoxContainer.new()
	buttons.custom_minimum_size.x = 240
	buttons.add_theme_constant_override("separation", 10)
	center.add_child(buttons)
	var title := Label.new()
	title.text = "JUEGO PURÉPECHA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("f1dfb1"))
	buttons.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Un pueblo, sus palabras y sus historias"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 11)
	buttons.add_child(subtitle)
	var new_button := add_button("Juego Nuevo", _new_game)
	load_button = add_button("Cargar partida", _load_game)
	load_button.disabled = not GameSession.has_save()
	add_button("Ajustes", _show_settings)
	status_label = Label.new()
	status_label.text = "Guardado automático durante el juego"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 10)
	buttons.add_child(status_label)
	_build_settings()
	new_button.grab_focus()

func add_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 38
	button.add_theme_font_size_override("font_size", 15)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("30463a")
	style.border_color = Color("bca570")
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color("4a6250")
	button.add_theme_stylebox_override("hover", hover)
	buttons.add_child(button)
	button.pressed.connect(callback)
	return button

func _new_game() -> void:
	if GameSession.has_save():
		var confirm := ConfirmationDialog.new()
		confirm.dialog_text = "¿Empezar de nuevo? Se reemplazará la partida guardada."
		confirm.title = "Juego Nuevo"
		confirm.ok_button_text = "Empezar"
		confirm.cancel_button_text = "Cancelar"
		add_child(confirm)
		confirm.confirmed.connect(func(): GameSession.start_new())
		confirm.canceled.connect(confirm.queue_free)
		confirm.popup_centered()
	else:
		GameSession.start_new()

func _load_game() -> void:
	if not GameSession.load_game():
		status_label.text = "No se pudo leer la partida guardada."

func _build_settings() -> void:
	settings = preload("res://settings_panel.gd").new()
	add_child(settings)
	settings.closed.connect(_close_settings)

func _show_settings() -> void:
	buttons.hide()
	settings.open()

func _close_settings() -> void:
	settings.hide()
	buttons.show()
	buttons.get_child(4).grab_focus()

func _input(event: InputEvent) -> void:
	if settings.visible and not event.is_echo() and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		settings.close()
