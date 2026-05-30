extends Weapon_State
class_name missile_state

@export var missile: PackedScene
@onready var missile_cooldown: Timer = $missile_cooldown
signal cooldown_started(weapon_name: String, duration: float)



func handle_input(event: InputEvent):
	if event.is_action_pressed("strzal") and missile_cooldown.is_stopped():
		missile_cooldown.start()
		cooldown_started.emit(name, missile_cooldown.wait_time)
		var missile_launch = missile.instantiate()
		missile_launch.damage *= PlayerData.get_attack_multiplier()
		missile_launch.global_position = character.global_position
		get_tree().current_scene.add_child(missile_launch)
		missile_launch.shooter = "Player"
		
		
