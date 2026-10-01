extends "res://npc.gd"

@export_enum("hierbas", "lena", "maiz", "recado") var quest_id: String = "hierbas"
@export var clothing_tint: Color = Color.WHITE

func _ready() -> void:
 super._ready()
 preload("res://npc_appearance.gd").apply($Sprite2D, {"hierbas": 1, "lena": 2, "maiz": 3, "recado": 4}[quest_id])
 $Nombre.text = QuestManager.QUESTS[quest_id]["speaker"]

func interact(_player: CharacterBody2D) -> void:
 DialogueManager.start_dialogue(QuestManager.talk(quest_id))
