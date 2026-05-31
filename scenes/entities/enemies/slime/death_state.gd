extends Enemy_State
const HealthDropper = preload("res://scenes/entities/collectables/health_dropper.gd")

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var timer: Timer = $Timer
@export var coin_scene: PackedScene
@export_range(0.0, 1.0, 0.01) var health_drop_chance: float = 0.12

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
	HealthDropper.try_drop(character.global_position, health_drop_chance)
	character.queue_free()
