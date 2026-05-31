extends Enemy_State
const HealthDropper = preload("res://scenes/entities/collectables/health_dropper.gd")

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var death_timer: Timer = $death_timer

@export var coin_scene: PackedScene
@export var coins_to_drop: int = 5
@export_range(0.0, 1.0, 0.01) var health_drop_chance: float = 0.18

var death_started: bool = false


func enter(data = {}) -> void:
	if death_started:
		return

	death_started = true
	character.velocity = Vector2.ZERO
	character.set_collision_layer_value(2, false)
	character.set_collision_mask_value(5, false)
	_disable_detection()

	animated_sprite_2d.stop()

	var tween: Tween = create_tween()
	tween.parallel().tween_property(animated_sprite_2d, "modulate", Color(1, 0.35, 0.35, 0.0), 0.45)
	tween.parallel().tween_property(animated_sprite_2d, "scale", animated_sprite_2d.scale * 0.65, 0.45)
	tween.parallel().tween_property(animated_sprite_2d, "rotation", animated_sprite_2d.rotation + 0.35, 0.45)

	death_timer.start()


func _on_death_timer_timeout() -> void:
	_drop_coins()
	HealthDropper.try_drop(character.global_position, health_drop_chance)
	character.queue_free()


func _drop_coins() -> void:
	if not coin_scene:
		return

	for i in coins_to_drop:
		var coin: Node2D = coin_scene.instantiate()
		coin.global_position = character.global_position + Vector2(
			randf_range(-26, 26),
			randf_range(-16, 16)
		)
		get_tree().current_scene.add_child(coin)


func _disable_detection() -> void:
	if character.has_node("detection/Seeing_Range"):
		character.get_node("detection/Seeing_Range").monitoring = false
	if character.has_node("detection/Attack_Range"):
		character.get_node("detection/Attack_Range").monitoring = false
