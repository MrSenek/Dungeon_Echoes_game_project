extends Node

signal health_changed(amount)
signal death()


var MAX_HEALTH: int
var CURRENT_HEALTH: int
var can_take_damage: bool = true

# Ta funkcja zostaje, wywołujemy ją zawsze przy zmianie HP
func set_health(amount):
	# Zabezpieczamy, żeby CURRENT_HEALTH nie przekroczyło MAX_HEALTH
	CURRENT_HEALTH = clamp(amount, 0, MAX_HEALTH)
	health_changed.emit(CURRENT_HEALTH)

func damage_taken(amount):
	if can_take_damage:
		can_take_damage = false
		set_health(CURRENT_HEALTH - amount) # Używamy set_health, by wysłać sygnał
		if CURRENT_HEALTH <= 0:
			death.emit()
		await get_tree().create_timer(0.2).timeout
		can_take_damage = true

func get_hp(amount):
	set_health(CURRENT_HEALTH + amount) # Używamy set_health, by wysłać sygnał

func _ready() -> void:
	if get_parent().is_in_group("enemy"):
		MAX_HEALTH = get_parent().stats.get_scaled_max_hp(PlayerData.current_round)
	else:
		PlayerData.stats_changed.connect(_on_player_stats_changed)
		MAX_HEALTH = PlayerData.max_health
	CURRENT_HEALTH = MAX_HEALTH
	set_health(CURRENT_HEALTH)

func _on_player_stats_changed():
	update_stats()

func update_stats():
	if get_parent().is_in_group("enemy"):
		MAX_HEALTH = get_parent().stats.get_scaled_max_hp(PlayerData.current_round)
	else:
		MAX_HEALTH = PlayerData.max_health
	set_health(CURRENT_HEALTH)
