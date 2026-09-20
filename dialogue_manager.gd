extends CanvasLayer

@onready var box: Control = $Box
@onready var text_label: RichTextLabel = $Box/DialogueText

var is_active: bool = false

func _ready() -> void:
	box.hide()

func start_dialogue(text: String) -> void:
	text_label.text = text
	box.show()
	is_active = true
	get_tree().paused = true
	# Evita que el mismo botonazo que abre el dialogo lo cierre de inmediato
	get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if is_active and event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		close_dialogue()

func close_dialogue() -> void:
	box.hide()
	is_active = false
	get_tree().paused = false
