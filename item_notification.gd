extends CanvasLayer

@onready var toast: PanelContainer = $Toast
@onready var text_label: RichTextLabel = $Toast/ToastText
var tween: Tween

func _ready() -> void:
	toast.modulate.a = 0.0 # Invisible al inicio
	Inventory.item_added.connect(_on_item_collected)

func _on_item_collected(_item_id: String, item_data: Dictionary) -> void:
	var display_name = item_data.get("purepecha", item_data.get("name"))
	text_label.text = "[center]Recogiste x1\n[color=yellow]" + display_name + "[/color][/center]"
	
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween()
	# Aparecer -> esperar 2 segundos -> desvanecer
	tween.tween_property(toast, "modulate:a", 1.0, 0.2)
	tween.tween_interval(2.0)
	tween.tween_property(toast, "modulate:a", 0.0, 0.5)
