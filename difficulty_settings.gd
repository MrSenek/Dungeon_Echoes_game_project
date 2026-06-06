extends Node

const EASY := "easy"
const NORMAL := "normal"
const HARD := "hard"

var current_difficulty: String = NORMAL

var profiles := {
	EASY: {
		"display_name": "EASY",
		"description": "More breathing room, softer enemy scaling.",
		"enemy_health_mult": 0.85,
		"enemy_attack_mult": 0.8,
		"wave_budget_base": 35,
		"wave_budget_per_wave": 25,
		"spawn_interval_wave_step": 0.055,
		"min_spawn_interval": 0.9,
		"burst_chance": 0.12,
		"max_burst_size": 2,
		"burst_start_wave": 5,
		"spawn_telegraph_time": 0.75,
		"health_drop_mult": 1.35,
		"coin_reward_mult": 1.2,
		"shop_price_mult": 0.9,
		"score_mult": 0.75,
		"starting_coins": 30,
		"enemy_unlock_wave_offset": 1,
	},
	NORMAL: {
		"display_name": "NORMAL",
		"description": "The intended balanced run.",
		"enemy_health_mult": 0.95,
		"enemy_attack_mult": 0.9,
		"wave_budget_base": 40,
		"wave_budget_per_wave": 30,
		"spawn_interval_wave_step": 0.065,
		"min_spawn_interval": 0.7,
		"burst_chance": 0.2,
		"max_burst_size": 3,
		"burst_start_wave": 4,
		"spawn_telegraph_time": 0.62,
		"health_drop_mult": 1.1,
		"coin_reward_mult": 1.0,
		"shop_price_mult": 1.0,
		"score_mult": 1.0,
		"starting_coins": 20,
		"enemy_unlock_wave_offset": 0,
	},
	HARD: {
		"display_name": "CLASSIC",
		"description": "Original pressure and scaling.",
		"enemy_health_mult": 1.0,
		"enemy_attack_mult": 1.0,
		"wave_budget_base": 40,
		"wave_budget_per_wave": 35,
		"spawn_interval_wave_step": 0.08,
		"min_spawn_interval": 0.5,
		"burst_chance": 0.25,
		"max_burst_size": 3,
		"burst_start_wave": 3,
		"spawn_telegraph_time": 0.55,
		"health_drop_mult": 1.0,
		"coin_reward_mult": 1.0,
		"shop_price_mult": 1.0,
		"score_mult": 1.5,
		"starting_coins": 20,
		"enemy_unlock_wave_offset": 0,
	},
}


func set_difficulty(difficulty: String) -> void:
	if profiles.has(difficulty):
		current_difficulty = difficulty
	else:
		current_difficulty = NORMAL


func get_profile() -> Dictionary:
	return profiles.get(current_difficulty, profiles[NORMAL])


func get_display_name() -> String:
	return str(get_profile().get("display_name", "NORMAL"))


func get_description() -> String:
	return str(get_profile().get("description", ""))


func get_float(key: String, fallback: float) -> float:
	return float(get_profile().get(key, fallback))


func get_int(key: String, fallback: int) -> int:
	return int(get_profile().get(key, fallback))


func get_wave_budget(wave: int) -> int:
	return get_int("wave_budget_base", 40) + wave * get_int("wave_budget_per_wave", 30)


func get_spawn_interval(base_spawn_interval: float, wave: int) -> float:
	var wave_step := get_float("spawn_interval_wave_step", 0.065)
	var profile_min := get_float("min_spawn_interval", 0.7)
	return max(profile_min, base_spawn_interval - wave * wave_step)


func get_enemy_health(value: int) -> int:
	return max(1, int(round(float(value) * get_float("enemy_health_mult", 1.0))))


func get_enemy_attack(value: float) -> float:
	return value * get_float("enemy_attack_mult", 1.0)


func get_health_drop_chance(base_chance: float) -> float:
	return min(base_chance * get_float("health_drop_mult", 1.0), 0.85)


func get_coin_reward(base_amount: int) -> int:
	var scaled_amount := float(base_amount) * get_float("coin_reward_mult", 1.0)
	var reward := int(floor(scaled_amount))
	if randf() < scaled_amount - reward:
		reward += 1
	return max(1, reward)


func get_shop_price(base_price: int) -> int:
	return max(1, int(round(float(base_price) * get_float("shop_price_mult", 1.0))))


func get_score_multiplier() -> float:
	return get_float("score_mult", 1.0)


func get_starting_coins() -> int:
	return get_int("starting_coins", 20)


func get_enemy_unlock_wave(min_wave: int) -> int:
	return max(1, min_wave + get_int("enemy_unlock_wave_offset", 0))
