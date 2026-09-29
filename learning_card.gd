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
	if not revealed or word_side:
		return
	var center := Vector2(size.x / 2.0, 25)
	match item_id:
		"hierbas_medicinales":
			draw_rect(Rect2(center + Vector2(-2, -8), Vector2(4, 24)), Color("3e6743"))
			for side in [-1, 1]:
				for y in [-7, 3]:
					draw_colored_polygon(PackedVector2Array([center + Vector2(0, y + 9), center + Vector2(side * 15, y), center + Vector2(side * 12, y + 10)]), Color("6ca15b"))
		"lena_seca":
			for y in [-6, 3, 12]:
				draw_rect(Rect2(center + Vector2(-21, y), Vector2(42, 7)), Color("886044"))
				draw_circle(center + Vector2(18, y + 3), 4, Color("d3ae74"))
		"mazorca":
			draw_rect(Rect2(center + Vector2(-8, -13), Vector2(16, 30)), Color("ddb54c"))
			for x in [-5, 1]:
				for y in [-10, -3, 4, 11]:
					draw_rect(Rect2(center + Vector2(x, y), Vector2(4, 5)), Color("f4d77a"))
			draw_line(center + Vector2(-13, 4), center + Vector2(-6, 19), Color("568053"), 4)
		"morral_recado":
			draw_arc(center + Vector2(0, -5), 11, PI, TAU, 16, Color("71533b"), 4)
			draw_rect(Rect2(center + Vector2(-18, -4), Vector2(36, 24)), Color("b68954"))
			draw_rect(Rect2(center + Vector2(-18, 2), Vector2(36, 5)), Color("cebb8d"))
