extends Enemy_State

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"

var attacked: bool = false

func enter(data = {}):
	attacked = false
	animated_sprite_2d.play("attack")


func update(delta: float):
	if character.player and character.player.has_node("HP") and not attacked:
		if character.player.global_position.x - character.global_position.x < 20:
			if (character.player.global_position.y - character.global_position.y) < 3:
				character.player.get_node("HP").damage_taken(50)
		attacked = true


func _on_animated_sprite_2d_animation_finished() -> void:
	enemy_state_machine.change_state("idle_state")
