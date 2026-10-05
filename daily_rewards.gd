extends Node

const FILE := "user://biblioteca_diaria.cfg"
const LIMIT := 3
var day := ""
var attempts := 0

func _ready() -> void:
 var config := ConfigFile.new()
 if config.load(FILE) == OK:
  day = str(config.get_value("library", "day", ""))
  attempts = maxi(0, int(config.get_value("library", "attempts", 0)))

func _roll_day() -> void:
 var today := Time.get_date_string_from_system()
 if day.is_empty() or today > day:
  day = today
  attempts = 0

func remaining() -> int:
 _roll_day()
 return maxi(0, LIMIT - attempts)

func begin_attempt() -> bool:
 _roll_day()
 attempts += 1
 var config := ConfigFile.new()
 config.set_value("library", "day", day)
 config.set_value("library", "attempts", attempts)
 # Reserve the attempt before cards are shown, so quitting does not restore it.
 if config.save(FILE) != OK:
  return false
 return attempts <= LIMIT
