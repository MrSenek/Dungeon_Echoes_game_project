extends Enemy_State
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var timer: Timer = $Timer
@export var coin_scene: PackedScene

func enter(data = {}):
	character.is_alive = false
	character.velocity = Vector2.ZERO
	character.set_collision_layer_value(2, false)
	timer.start()
	animated_sprite_2d.play("death")

func _on_timer_timeout() -> void:
	var coin: Node2D = coin_scene.instantiate()
	coin.global_position = character.global_position
	get_tree().current_scene.add_child(coin)
	character.queue_free()
