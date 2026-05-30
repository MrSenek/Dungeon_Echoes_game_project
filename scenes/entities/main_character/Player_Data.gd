extends Node
signal stats_changed
signal crit_happened

@export var max_health: int = 100:
	set(value):
		max_health = value
		stats_changed.emit()
@export var defence: int = 10
@export var attack: float = 1
var player_coins: int = 20
var owned_weapons = ["fireball"]
var max_round: int = 0
var current_round: int = 0
var tutorial_seen_this_session = false


const SAVE_PATH = "user://player_data.json"
const DEFAULT_MAX_HEALTH := 100
const DEFAULT_DEFENCE := 10
const DEFAULT_ATTACK := 1.0
const DEFAULT_PLAYER_COINS := 20
const DEFAULT_OWNED_WEAPONS := ["fireball"]

func _ready() -> void:
	#load_data()
	pass





func reset_data() -> void:
	max_health = DEFAULT_MAX_HEALTH
	defence = DEFAULT_DEFENCE
	attack = DEFAULT_ATTACK
	player_coins = DEFAULT_PLAYER_COINS
	owned_weapons = DEFAULT_OWNED_WEAPONS.duplicate()
	max_round = 0
	current_round = 0


func save_game() -> void:
	var data = {
		"max_health": max_health,
		"defence": defence,
		"attack": attack,
		"player_coins":player_coins,
		"owned_weapons":owned_weapons,
		"max_round":max_round
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t")
		file.store_line(json_string)
		file.close()

func load_data() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var file = FileAccess.open(SAVE_PATH,FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var data = json.data
			max_health = int(data.get("max_health", max_health))
			defence = int(data.get("defence", defence))
			attack = float(data.get("attack", attack))
			player_coins = int(data.get("player_coins", player_coins))
			owned_weapons = data.get("owned_weapons", owned_weapons)
			max_round = int(data.get("max_round", max_round))
			current_round = 0
			
			return true

	return false
