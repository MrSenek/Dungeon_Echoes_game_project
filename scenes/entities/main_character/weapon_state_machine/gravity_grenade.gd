extends Weapon_State

class_name gravity_grenade
@export var grav_grenade: PackedScene
@onready var weapon_cooldown: Timer = $weapon_cooldown



signal cooldown_started(weapon_name: String, duration: float)

var can_shoot: bool = true

func handle_input(event: InputEvent):
	if event.is_action_pressed("strzal") and can_shoot:
		can_shoot = false
		cooldown_started.emit(name, weapon_cooldown.wait_time)
		weapon_cooldown.start()
		var grenade = grav_grenade.instantiate()
		grenade.global_position = character.global_position
		grenade.dir = character.dir
		get_tree().current_scene.add_child(grenade)


func _on_weapon_cooldown_timeout() -> void:
	can_shoot = true
