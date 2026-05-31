extends Node

signal health_changed(current, max)
signal death()


var MAX_HEALTH: int
var CURRENT_HEALTH: int
var can_take_damage: bool = true
var is_dead: bool = false
var original_color
var flash_token: int = 0

# Ta funkcja zostaje, wywołujemy ją zawsze przy zmianie HP
func set_health(amount):
	# Zabezpieczamy, żeby CURRENT_HEALTH nie przekroczyło MAX_HEALTH
	CURRENT_HEALTH = clamp(amount, 0, MAX_HEALTH)
	health_changed.emit(CURRENT_HEALTH, MAX_HEALTH)

func damage_taken(amount):
	if is_dead and amount > 0:
		return
	if can_take_damage:
		can_take_damage = false
		set_health(CURRENT_HEALTH - amount) # Używamy set_health, by wysłać sygnał
		if CURRENT_HEALTH <= 0:
			is_dead = true
			if get_parent().is_in_group("enemy"):
				emit_signal("death")
			else:
				if get_parent().is_alive:
					emit_signal("death")
		flash_token += 1
		await flash(flash_token)
		can_take_damage = true
		get_parent().modulate = original_color

func get_hp(amount):
	if is_dead:
		return
	set_health(CURRENT_HEALTH + amount) # Używamy set_health, by wysłać sygnał

func _ready() -> void:
	original_color = get_parent().modulate
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
		set_health(MAX_HEALTH)

func flash(token: int):
	var org_color = original_color
	get_parent().modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	if token != flash_token:
		return
	get_parent().modulate = org_color
	await get_tree().create_timer(0.1).timeout
	if token != flash_token:
		return
	get_parent().modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	if token != flash_token:
		return
	get_parent().modulate = org_color
	get_parent().modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	if token != flash_token:
		return
	get_parent().modulate = org_color
