extends Node

var monedas_plata: int = 0
var monedas_bronce: int = 0

func anadir_bronce(cantidad: int) -> void:
 if cantidad <= 0:
  return
 monedas_bronce += cantidad
 @warning_ignore("integer_division")
 var conversion: int = monedas_bronce / 10
 monedas_plata += conversion
 monedas_bronce %= 10

func anadir_plata(cantidad: int) -> void:
 if cantidad > 0:
  monedas_plata += cantidad

func total_bronce() -> int:
 return monedas_plata * 10 + monedas_bronce

func gastar_bronce(cantidad: int) -> bool:
 if cantidad <= 0 or total_bronce() < cantidad:
  return false
 var remaining: int = total_bronce() - cantidad
 monedas_plata = int(remaining / 10)
 monedas_bronce = remaining % 10
 return true
