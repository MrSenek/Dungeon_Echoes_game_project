extends Weapon_State

class_name gravity_grenade
@export var grav_grenade: PackedScene
signal cooldown_started(weapon_name: String, duration: float)

func handle_input(event: InputEvent):
	if event.is_action_pressed("strzal"):
		var grenade = grav_grenade.instantiate()
		grenade.global_position = character.global_position
		grenade.dir = character.dir
		get_tree().current_scene.add_child(grenade)
