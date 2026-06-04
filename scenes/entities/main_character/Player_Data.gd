extends Node
signal stats_changed
signal crit_happened
signal combo_changed(combo_count: int, damage_multiplier: float, speed_multiplier: float)
signal combo_milestone_reached(combo_count: int, milestone_name: String)
signal combo_kill_registered(source: String, combo_count: int)
signal overdrive_changed(active: bool)
signal wave_cleared(wave_number: int)
signal run_stats_changed

@export var max_health: int = 100:
	set(value):
		max_health = value
		stats_changed.emit()
@export var defence: int = 10
@export var attack: float = 1
var movement_speed_multiplier: float = 1.0:
	set(value):
		movement_speed_multiplier = value
		stats_changed.emit()
var cooldown_upgrade_multiplier: float = 1.0
var dash_damage_multiplier: float = 1.0
var player_coins: int = 200
var owned_weapons = ["fireball"]
var max_round: int = 0
var current_round: int = 0
var run_coins_collected: int = 0
var run_enemies_killed: int = 0
var run_best_combo: int = 0
var run_waves_cleared: int = 0
var tutorial_seen_this_session = false
var combo_count: int = 0
var combo_damage_multiplier: float = 1.0
var combo_speed_multiplier: float = 1.0
var combo_time_left: float = 0.0
var overdrive_active: bool = false
var overdrive_time_left: float = 0.0
var reached_milestones: Array[int] = []

const COMBO_WINDOW := 3.25
const COMBO_DECAY_WINDOW := 1.25
const MAX_COMBO := 12
const COMBO_DAMAGE_STEP := 0.04
const COMBO_SPEED_STEP := 0.025
const MAX_COMBO_DAMAGE_MULTIPLIER := 1.45
const MAX_COMBO_SPEED_MULTIPLIER := 1.25
const OVERDRIVE_DURATION := 0.75
const FLOW_HEAL_REWARD := 4
const HOT_STREAK_COIN_REWARD := 2
const RAMPAGE_HEAL_REWARD := 8
const OVERDRIVE_COIN_REWARD := 5


const SAVE_PATH = "user://player_data.json"
const DEFAULT_MAX_HEALTH := 100
const DEFAULT_DEFENCE := 10
const DEFAULT_ATTACK := 1.0
const DEFAULT_MOVEMENT_SPEED_MULTIPLIER := 1.0
const DEFAULT_COOLDOWN_UPGRADE_MULTIPLIER := 1.0
const DEFAULT_DASH_DAMAGE_MULTIPLIER := 1.0
const DEFAULT_PLAYER_COINS := 20
const DEFAULT_OWNED_WEAPONS := ["fireball"]



func _process(delta: float) -> void:
	if overdrive_active:
		overdrive_time_left -= delta
		if overdrive_time_left <= 0.0:
			_set_overdrive(false)

	if combo_count <= 0:
		return
	if overdrive_active:
		combo_time_left = COMBO_WINDOW
		return

	combo_time_left -= delta
	if combo_time_left <= 0.0:
		decay_combo()


func register_enemy_kill(source: String = "weapon") -> void:
	var combo_gain := 2 if source == "dash" else 1
	combo_count = min(combo_count + combo_gain, MAX_COMBO)
	run_enemies_killed += 1
	run_best_combo = max(run_best_combo, combo_count)
	combo_time_left = COMBO_WINDOW
	_update_combo_multipliers()
	combo_changed.emit(combo_count, combo_damage_multiplier, combo_speed_multiplier)
	combo_kill_registered.emit(source, combo_count)
	run_stats_changed.emit()
	_check_combo_milestones()


func add_coins(amount: int, count_for_run: bool = true) -> void:
	if amount <= 0:
		return
	player_coins += amount
	if count_for_run:
		run_coins_collected += amount
	run_stats_changed.emit()


func start_run() -> void:
	current_round = 0
	run_coins_collected = 0
	run_enemies_killed = 0
	run_best_combo = 0
	run_waves_cleared = 0
	reset_combo()
	run_stats_changed.emit()


func register_wave_cleared(wave_number: int) -> void:
	run_waves_cleared = max(run_waves_cleared, wave_number)
	wave_cleared.emit(wave_number)
	run_stats_changed.emit()


func decay_combo() -> void:
	combo_count = max(combo_count - 1, 0)
	if combo_count <= 0:
		reset_combo()
		return

	combo_time_left = COMBO_DECAY_WINDOW
	_update_combo_multipliers()
	_forget_unreached_milestones()
	combo_changed.emit(combo_count, combo_damage_multiplier, combo_speed_multiplier)


func reset_combo() -> void:
	combo_count = 0
	combo_time_left = 0.0
	combo_damage_multiplier = 1.0
	combo_speed_multiplier = 1.0
	reached_milestones.clear()
	_set_overdrive(false)
	combo_changed.emit(combo_count, combo_damage_multiplier, combo_speed_multiplier)


func get_attack_multiplier() -> float:
	return attack * combo_damage_multiplier


func get_cooldown_multiplier() -> float:
	var combo_cooldown_multiplier := 1.0
	if overdrive_active:
		combo_cooldown_multiplier = 0.65
	elif combo_count >= 6:
		combo_cooldown_multiplier = 0.8
	elif combo_count >= 3:
		combo_cooldown_multiplier = 0.9
	return max(cooldown_upgrade_multiplier * combo_cooldown_multiplier, 0.45)


func _update_combo_multipliers() -> void:
	combo_damage_multiplier = min(1.0 + combo_count * COMBO_DAMAGE_STEP, MAX_COMBO_DAMAGE_MULTIPLIER)
	combo_speed_multiplier = min(1.0 + combo_count * COMBO_SPEED_STEP, MAX_COMBO_SPEED_MULTIPLIER)


func _forget_unreached_milestones() -> void:
	for milestone in reached_milestones.duplicate():
		if milestone > combo_count:
			reached_milestones.erase(milestone)


func _check_combo_milestones() -> void:
	var milestones := {
		3: "FLOW",
		6: "HOT STREAK",
		9: "RAMPAGE",
		12: "OVERDRIVE",
	}
	for milestone in milestones.keys():
		if combo_count >= milestone and not reached_milestones.has(milestone):
			reached_milestones.append(milestone)
			combo_milestone_reached.emit(milestone, milestones[milestone])
			_apply_combo_reward(milestone)
			if milestone == 12:
				_set_overdrive(true)


func _apply_combo_reward(milestone: int) -> void:
	match milestone:
		3:
			_heal_player(FLOW_HEAL_REWARD)
		6:
			add_coins(HOT_STREAK_COIN_REWARD, true)
		9:
			_heal_player(RAMPAGE_HEAL_REWARD)
		12:
			add_coins(OVERDRIVE_COIN_REWARD, true)


func _heal_player(amount: int) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if not tree:
		return

	var player := tree.get_first_node_in_group("Player")
	if not player or not player.has_node("HP"):
		return

	var hp = player.get_node("HP")
	if hp.has_method("get_hp"):
		hp.get_hp(amount)


func _set_overdrive(active: bool) -> void:
	if active:
		overdrive_time_left = OVERDRIVE_DURATION
	if overdrive_active == active:
		return
	overdrive_active = active
	if not active:
		overdrive_time_left = 0.0
	overdrive_changed.emit(overdrive_active)




func reset_data() -> void:
	max_health = DEFAULT_MAX_HEALTH
	defence = DEFAULT_DEFENCE
	attack = DEFAULT_ATTACK
	movement_speed_multiplier = DEFAULT_MOVEMENT_SPEED_MULTIPLIER
	cooldown_upgrade_multiplier = DEFAULT_COOLDOWN_UPGRADE_MULTIPLIER
	dash_damage_multiplier = DEFAULT_DASH_DAMAGE_MULTIPLIER
	player_coins = DEFAULT_PLAYER_COINS
	owned_weapons = DEFAULT_OWNED_WEAPONS.duplicate()
	max_round = 0
	current_round = 0
	run_coins_collected = 0
	run_enemies_killed = 0
	run_best_combo = 0
	run_waves_cleared = 0
	tutorial_seen_this_session = false
	reset_combo()


func save_game() -> void:
	var data = {
		"max_health": max_health,
		"defence": defence,
		"attack": attack,
		"movement_speed_multiplier": movement_speed_multiplier,
		"cooldown_upgrade_multiplier": cooldown_upgrade_multiplier,
		"dash_damage_multiplier": dash_damage_multiplier,
		"player_coins":player_coins,
		"owned_weapons":owned_weapons,
		"max_round":max_round,
		"tutorial_seen_this_session": tutorial_seen_this_session
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
			movement_speed_multiplier = float(data.get("movement_speed_multiplier", movement_speed_multiplier))
			cooldown_upgrade_multiplier = float(data.get("cooldown_upgrade_multiplier", cooldown_upgrade_multiplier))
			dash_damage_multiplier = float(data.get("dash_damage_multiplier", dash_damage_multiplier))
			player_coins = int(data.get("player_coins", player_coins))
			owned_weapons = data.get("owned_weapons", owned_weapons)
			max_round = int(data.get("max_round", max_round))
			tutorial_seen_this_session = bool(data.get("tutorial_seen_this_session", max_round > 0))
			current_round = 0
			
			return true

	return false


func mark_tutorial_seen() -> void:
	tutorial_seen_this_session = true
	save_game()
