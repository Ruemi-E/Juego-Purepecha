# Biblioteca y comercios

La zona nueva está al sur del pueblo. Sigue los letreros y el camino central. En el minimapa: B = biblioteca, C = comida, R = remedios, H = herrería. E frente a una puerta entra, E junto al NPC abre el menú y E en la salida vuelve al pueblo. Esc cierra cada ventana. Los interiores usan coordenadas separadas dentro del mismo mundo, conservando objetos recogidos y misiones; guardar y cargar dentro es compatible.

## Biblioteca

Elena abre un juego de memoria de ocho cartas (cuatro parejas). Se empareja cada palabra con su objeto y significado. Se puede estudiar antes. Hay doce turnos, dos monedas de bronce por pareja, cuatro extra al completar en cuatro turnos o dos extra al completar en cinco o seis. El premio se paga una sola vez al terminar, incluso al alcanzar el límite con parejas parciales. Abandonar no paga. Se puede repetir para practicar. El diccionario queda dedicado a consulta.

## Comercio

Los precios están en bronce y el pago usa también la plata (1 plata = 10 bronce). Comida vende agua y pan. Remedios vende objetos de inventario, sin efectos de salud hasta que exista ese sistema. No son instrucciones ni recetas de uso real.

La herrería no añade herramientas jugables antes de que se definan: tiene pestañas Comprar y Reparar con estados vacíos. El circuito de compra y reparación está implementado. Para incorporar una herramienta, se añade a Inventory.item_database:

```gdscript
"id_futuro": {
    "name": "Nombre", "purepecha": "Nombre validado", "desc": "Descripción",
    "shop": "smith", "price": 12,
    "max_durability": 100, "repairable": true, "repair_price_per_point": 1
}
```

Cada ejemplar obtiene su propio uid y estado en Inventory.equipment. El futuro sistema de uso puede llamar Inventory.damage_equipment(uid, cantidad). La reparación restaura el máximo y cobra el desgaste por la tarifa. Inventario y durabilidad se guardan. Los nombres nuevos de remedios no se presentan como traducciones purépechas verificadas.

## Archivos principales

- village_services.gd: ubicaciones, casas existentes, interiores y NPC.
- service_interaction.gd: interacción mediante E.
- services_ui.gd: juego, resultados y ventanas comerciales.
- learning_card.gd: cartas e ilustraciones dibujadas.
- shop_transactions.gd: catálogo, compras y reparaciones.

Se mantienen los identificadores de las misiones y el formato de guardado versión 1; las partidas anteriores cargan sin el campo opcional equipment.
