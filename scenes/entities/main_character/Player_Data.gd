extends Node
signal stats_changed

@export var max_health: int = 100:
	set(value):
		max_health = value
		stats_changed.emit()
@export var defence: int = 10
@export var attack: float = 1
var player_coins = 0
var current_health = 10
var owned_weapons = ["fireball"]
var max_round = 0
var current_round = 0


const SAVE_PATH = "user://player_data.json"

func _ready() -> void:
	#load_data()
	pass





func save_game():
	var data = {
		"max_health": max_health,
		"defence": defence,
		"attack": attack,
		"player_coins":player_coins,
		"current_health":current_health,
		"owned_weapons":owned_weapons,
		"max_round":max_round,
		"current_round":current_round
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t")
		file.store_line(json_string)
		file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH,FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var data = json.data
			max_health = data.get("max_health", max_health)
			defence = data.get("defence", defence)
			attack = data.get("attack", attack)
			player_coins = data.get("player_coins", player_coins)
			current_health = data.get("current_health", current_health)
			owned_weapons = data.get("owned_weapons", owned_weapons)
			max_round = data.get("max_round", max_round)
			
			
