extends "res://npc.gd"

@export_enum("hierbas", "lena", "maiz", "recado") var quest_id: String = "hierbas"
@export var clothing_tint: Color = Color.WHITE

func _ready() -> void:
 super._ready()
 $Sprite2D.self_modulate = clothing_tint
 $Nombre.text = QuestManager.QUESTS[quest_id]["speaker"]

func interact(_player: CharacterBody2D) -> void:
 DialogueManager.start_dialogue(QuestManager.talk(quest_id))
