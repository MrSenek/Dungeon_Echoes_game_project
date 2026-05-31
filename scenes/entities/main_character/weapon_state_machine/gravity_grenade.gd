extends Weapon_State

class_name gravity_grenade
@export var grav_grenade: PackedScene
@onready var weapon_cooldown: Timer = $weapon_cooldown

var base_cooldown := 0.0


signal cooldown_started(weapon_name: String, duration: float)

var can_shoot: bool = true


func _ready() -> void:
	base_cooldown = weapon_cooldown.wait_time


func handle_input(event: InputEvent):
	if event.is_action_pressed("strzal") and can_shoot:
		can_shoot = false
		var cooldown_duration := base_cooldown * PlayerData.get_cooldown_multiplier()
		cooldown_started.emit(name, cooldown_duration)
		weapon_cooldown.start(cooldown_duration)
		var grenade = grav_grenade.instantiate()
		grenade.global_position = character.global_position
		grenade.dir = character.dir
		get_tree().current_scene.add_child(grenade)


func _on_weapon_cooldown_timeout() -> void:
	can_shoot = true
