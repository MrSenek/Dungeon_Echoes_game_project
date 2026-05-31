extends Enemy_State
const HealthDropper = preload("res://scenes/entities/collectables/health_dropper.gd")

@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"
@onready var death_timer: Timer = $death_timer
@export var coin_scene: PackedScene
@export var coins_to_drop: int = 3
@export_range(0.0, 1.0, 0.01) var health_drop_chance: float = 0.18


func enter(data = {}):
	character.set_collision_layer_value(2, false)
	death_timer.start()
	sprite_2d.stop()
	sprite_2d.frame = 3



func _on_death_timer_timeout() -> void:
	for i in coins_to_drop:
		var coin = coin_scene.instantiate()
		coin.global_position = character.global_position + Vector2(
			randf_range(-20, 20),
			randf_range(-12, 12)
		)
		get_tree().current_scene.add_child(coin)
	HealthDropper.try_drop(character.global_position, health_drop_chance)
	character.queue_free()
