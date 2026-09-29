extends Node2D

var action: Callable
var prompt: String = "E · Hablar"
var hint: Label

func _ready() -> void:
	add_to_group("interactables")
	hint = Label.new()
	hint.text = prompt
	hint.position = Vector2(-85, -40)
	hint.size.x = 170
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_theme_font_size_override("font_size", 9)
	hint.add_theme_color_override("font_shadow_color", Color.BLACK)
	hint.add_theme_constant_override("outline_size", 3)
	hint.add_theme_color_override("font_outline_color", Color("26352a"))
	add_child(hint)
	hint.hide()

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	hint.visible = is_instance_valid(player) and global_position.distance_to(player.global_position) <= 54.0

func interact(player: CharacterBody2D) -> void:
	if action.is_valid():
		action.call(player)
