extends CanvasLayer

@onready var panel: Control = $Panel
@onready var text_display: RichTextLabel = $Panel/RichTextLabel

var is_open: bool = false

func _ready() -> void:
	panel.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_dictionary"):
		# Solo se abre si el jugador ya recibió el cuaderno de los abuelos
		if not DictionaryManager.has_dictionary:
			return
		
		get_viewport().set_input_as_handled()
		toggle_dictionary()

func toggle_dictionary() -> void:
	is_open = !is_open
	panel.visible = is_open
	get_tree().paused = is_open

	if is_open:
		refresh_content()

func refresh_content() -> void:
	text_display.clear()
	for word in DictionaryManager.known_words:
		var def = DictionaryManager.known_words[word]
		text_display.append_text("[b][color=#8a3324]" + word.capitalize() + "[/color][/b]: " + def + "\n\n")
