extends Area2D

# Identificador que guardará el inventario
@export var item_id: String = "itsï"

func interact(_player: CharacterBody2D) -> void:
	# Guarda el objeto en el inventario global
	Inventory.add_item(item_id)
	print("¡Recogiste: ", item_id, "!")
	# Elimina el objeto del mapa
	queue_free() 
