extends Node2D

var action: Callable
var prompt: String = "E · Hablar"
var floating_name := false
var hint: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	if floating_name:
		var bubble := StyleBoxFlat.new()
		bubble.bg_color = Color("253a37",0.96)
		bubble.border_color = Color("d4bc81")
		bubble.set_border_width_all(1)
		bubble.set_corner_radius_all(4)
		bubble.set_content_margin_all(5)
		hint.add_theme_stylebox_override("normal",bubble)
		hint.position.y = -32
		hint.z_index = 12
	add_child(hint)
	hint.hide()

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	hint.visible = not get_tree().paused and is_instance_valid(player) and global_position.distance_to(player.global_position) <= 54.0

func interact(player: CharacterBody2D) -> void:
	if action.is_valid():
		action.call(player)
