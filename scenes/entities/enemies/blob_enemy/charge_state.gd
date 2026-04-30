extends Enemy_State

@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"

func enter(data = {}):
	print("enter charge")
	sprite_2d.play("charge_anim")

func exit():
	sprite_2d.play("new_animation")



func _on_sprite_2d_animation_finished() -> void:
	enemy_state_machine.change_state("attack_state")
