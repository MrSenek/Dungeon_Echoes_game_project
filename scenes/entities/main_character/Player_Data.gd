extends Node
signal stats_changed
signal crit_happened
signal combo_changed(combo_count: int, damage_multiplier: float, speed_multiplier: float)

@export var max_health: int = 100:
	set(value):
		max_health = value
		stats_changed.emit()
@export var defence: int = 10
@export var attack: float = 1
var player_coins: int = 200
var owned_weapons = ["fireball"]
var max_round: int = 0
var current_round: int = 0
var tutorial_seen_this_session = false
var combo_count: int = 0
var combo_damage_multiplier: float = 1.0
var combo_speed_multiplier: float = 1.0
var combo_time_left: float = 0.0

const COMBO_WINDOW := 3.0
const MAX_COMBO := 12
const COMBO_DAMAGE_STEP := 0.04
const COMBO_SPEED_STEP := 0.025
const MAX_COMBO_DAMAGE_MULTIPLIER := 1.45
const MAX_COMBO_SPEED_MULTIPLIER := 1.25


const SAVE_PATH = "user://player_data.json"
const DEFAULT_MAX_HEALTH := 100
const DEFAULT_DEFENCE := 10
const DEFAULT_ATTACK := 1.0
const DEFAULT_PLAYER_COINS := 200
const DEFAULT_OWNED_WEAPONS := ["fireball"]

func _ready() -> void:
	#load_data()
	pass


func _process(delta: float) -> void:
	if combo_count <= 0:
		return

	combo_time_left -= delta
	if combo_time_left <= 0.0:
		reset_combo()


func register_enemy_kill() -> void:
	combo_count = min(combo_count + 1, MAX_COMBO)
	combo_time_left = COMBO_WINDOW
	combo_damage_multiplier = min(1.0 + combo_count * COMBO_DAMAGE_STEP, MAX_COMBO_DAMAGE_MULTIPLIER)
	combo_speed_multiplier = min(1.0 + combo_count * COMBO_SPEED_STEP, MAX_COMBO_SPEED_MULTIPLIER)
	combo_changed.emit(combo_count, combo_damage_multiplier, combo_speed_multiplier)


func reset_combo() -> void:
	combo_count = 0
	combo_time_left = 0.0
	combo_damage_multiplier = 1.0
	combo_speed_multiplier = 1.0
	combo_changed.emit(combo_count, combo_damage_multiplier, combo_speed_multiplier)


func get_attack_multiplier() -> float:
	return attack * combo_damage_multiplier




func reset_data() -> void:
	max_health = DEFAULT_MAX_HEALTH
	defence = DEFAULT_DEFENCE
	attack = DEFAULT_ATTACK
	player_coins = DEFAULT_PLAYER_COINS
	owned_weapons = DEFAULT_OWNED_WEAPONS.duplicate()
	max_round = 0
	current_round = 0
	reset_combo()


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
