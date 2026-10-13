extends Button

var item_id: String
var word_side: bool
var revealed: bool = false
var matched: bool = false
var caption: Label

func _ready() -> void:
	custom_minimum_size = Vector2(132, 76)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	caption = Label.new()
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 13)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caption)
	refresh()

func refresh() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("426957") if matched else (Color("eee0ba") if revealed else Color("304955"))
	style.border_color = Color("a7ce8f") if matched else Color("b89d64")
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("disabled", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.border_color = Color("ffe4a0")
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", hover)
	caption.add_theme_color_override("font_color", Color("fff0c9") if not revealed or matched else Color("28382d"))
	if revealed:
		var data: Dictionary = DictionaryManager.Vocabulary.ENTRIES[item_id]
		caption.text = data["word"] if word_side else "\n\n" + str(data["meaning"])
	else:
		caption.text = "?"
	disabled = matched
	queue_redraw()

func _draw() -> void:
	if revealed and not word_side:
		draw_texture_rect(preload("res://item_images.gd").icon(item_id),Rect2(size.x/2.0-18,5,36,36),false)
