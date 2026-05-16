extends Weapon_State
class_name missile_state

@export var missile: PackedScene
@onready var missile_cooldown: Timer = $missile_cooldown

func enter():
	print("missile state")

func handle_input(event: InputEvent):
	if event.is_action_pressed("strzal") and missile_cooldown.is_stopped():
		missile_cooldown.start()
		var missile_launch = missile.instantiate()
		missile_launch.global_position = character.global_position
		get_tree().current_scene.add_child(missile_launch)
		missile_launch.shooter = "Player"
		
		
