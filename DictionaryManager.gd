extends Node

var has_dictionary: bool = false

var known_words: Dictionary = {
    "itsï": "Agua.",
    "kurhinda": "Pan tradicional.",
    "tátita": "Abuelo o señor mayor (forma de respeto).",
    "nánita": "Abuela o señora mayor.",
    "jántani": "Ir, caminar, andar.",
    "diosï meiamu": "Gracias / Que Dios te lo pague."
}

func unlock_word(word: String, definition: String) -> void:
    known_words[word.to_lower()] = definition

const Vocabulary = preload("res://learning_words.gd")
var consulted: Dictionary = {}
var encountered: Dictionary = {}
var practice: Dictionary = {}

func word_for(item_id: String) -> String:
    return str(Vocabulary.ENTRIES[item_id]["word"])

func consult(item_id: String) -> void:
    if Vocabulary.ENTRIES.has(item_id):
        consulted[item_id] = true
        encountered[item_id] = true

func reset_learning() -> void:
    consulted.clear()
    encountered.clear()
    practice.clear()

func record_answer(item_id: String, correct: bool) -> void:
    var stats: Dictionary = practice.get(item_id, {"attempts": 0, "correct": 0})
    stats["attempts"] += 1
    if correct:
        stats["correct"] += 1
    practice[item_id] = stats

func restore_learning(data: Dictionary) -> void:
    reset_learning()
    for id in Vocabulary.ENTRIES:
        if data.get("consulted", {}).get(id, false):
            consulted[id] = true
        if data.get("encountered", {}).get(id, false):
            encountered[id] = true
        var stats = data.get("practice", {}).get(id, {})
        if stats is Dictionary and not stats.is_empty():
            practice[id] = {"attempts": maxi(0, int(stats.get("attempts", 0))), "correct": maxi(0, int(stats.get("correct", 0)))}
