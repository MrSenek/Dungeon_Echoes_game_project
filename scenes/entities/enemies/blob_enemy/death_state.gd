extends Enemy_State
@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"
@onready var death_timer: Timer = $death_timer
@export var coin: PackedScene

func enter(data = {}):
	character.set_collision_layer_value(2, false)
	death_timer.start()
	sprite_2d.stop()
	sprite_2d.frame = 3



func _on_death_timer_timeout() -> void:
	var moneta = coin.instantiate()
	moneta.global_position = character.global_position
	get_tree().current_scene.add_child(moneta)
	character.queue_free()
