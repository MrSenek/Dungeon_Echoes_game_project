extends Resource
class_name Stats

@export var base_max_hp: int = 50
@export var base_attack: float = 1.0

#wave stats
@export var spawn_cost: int = 10
@export var min_wave: int = 1

#wave scaling
@export var health_scaling: int = 5
@export var attack_scaling: float = 0.2


func get_scaled_max_hp(round: int) -> int:
	var scaled_hp := base_max_hp + (round - 1) * health_scaling
	return DifficultySettings.get_enemy_health(scaled_hp)


func get_scaled_attack(round: int) -> float:
	var scaled_attack := base_attack + (round - 1) * attack_scaling
	return DifficultySettings.get_enemy_attack(scaled_attack)
