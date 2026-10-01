extends CanvasLayer

@onready var toast: PanelContainer = $Toast
@onready var text_label: RichTextLabel = $Toast/ToastText
var tween: Tween
var last_item: String = ""
var last_time: int = 0
var amount: int = 0

func _ready() -> void:
 layer = 9
 toast.modulate.a = 0.0
 toast.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 toast.custom_minimum_size = Vector2(154, 34)
 toast.size = Vector2(154, 34)
 toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
 Inventory.item_added.connect(_on_item_collected)

func _process(_delta: float) -> void:
 var y: float = 242.0
 if is_instance_valid(QuestHud.floating):
  y = maxf(y, QuestHud.floating.position.y + QuestHud.floating.size.y + 8.0)
 toast.position = Vector2(8, minf(y, get_viewport().get_visible_rect().size.y - 88))
 toast.visible = is_instance_valid(get_tree().get_first_node_in_group("player")) and not get_tree().paused

func _on_item_collected(item_id: String, item_data: Dictionary) -> void:
 var now: int = Time.get_ticks_msec()
 amount = amount + 1 if last_item == item_id and now - last_time < 500 else 1
 last_item = item_id
 last_time = now
 var display_name: String = str(item_data.get("purepecha", item_data.get("name", item_id)))
 show_message("[center]Recogiste x%d\n[color=yellow]%s[/color][/center]" % [amount, display_name])

func show_message(message: String) -> void:
 text_label.text = message
 if tween and tween.is_running():
  tween.kill()
 tween = create_tween()
 tween.tween_property(toast, "modulate:a", 1.0, 0.15)
 tween.tween_interval(2.0)
 tween.tween_property(toast, "modulate:a", 0.0, 0.4)
