extends Node

var monedas_plata: int = 0
var monedas_bronce: int = 0

func anadir_bronce(cantidad: int):
	monedas_bronce += cantidad
	# Conversión automática: 10 bronce = 1 plata
	if monedas_bronce >= 10:
		monedas_plata += monedas_bronce / 10
		monedas_bronce = monedas_bronce % 10
