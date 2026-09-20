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
