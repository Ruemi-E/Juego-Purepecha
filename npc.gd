extends Area2D

var introduced: bool = false

func interact(_player: CharacterBody2D) -> void:
	if not DictionaryManager.has_dictionary:
		DictionaryManager.has_dictionary = true
		Inventory.add_item("morral_recado")
		Inventory.add_item("diccionario")
		
		DialogueManager.start_dialogue(
			"[color=yellow]Tátita:[/color]\n" +
			"Hijo, lleva este morral con tu tía en el pueblo vecino.\n" +
			"El camino es largo. Llévate este cuaderno para que recuerdes nuestras palabras.\n" +
			"[color=green](Presiona 'J' para consultar tu diccionario en cualquier momento).[/color]"
		)
		introduced = true
	else:
		DialogueManager.start_dialogue(
			"[color=yellow]Tátita:[/color]\n" +
			"¡Jántani! (Ve con bien). Recuerda consultar tu libreta si olvidas alguna palabra por el camino."
		)



func _on_area_interaccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$GloboDeTexto.show()

func _on_area_interaccion_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$GloboDeTexto.hide()
