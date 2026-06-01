extends State

@onready var camera_2d: Camera2D = $"../../Camera2D"
@onready var death_timer: Timer = $death_timer
@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"



var target_zoom := Vector2(10, 10)
var zoom_speed := 2.0
var death_tween: Tween

func enter(data = {}):
	character.velocity = Vector2.ZERO
	character.set_collision_layer_value(1, false)
	character.set_collision_mask_value(1, false)
	character.set_collision_mask_value(2, false)
	character.set_collision_mask_value(3, false)
	character.set_collision_mask_value(4, false)
	character.set_collision_mask_value(5, false)
	if character.has_node("low_hp_indicator"):
		character.get_node("low_hp_indicator").visible = false
	if character.has_node("heart_beat"):
		character.get_node("heart_beat").stop()
	_play_death_animation()
	death_timer.start()
	Engine.time_scale = 0.25


func exit():
	Engine.time_scale = 1
	if death_tween:
		death_tween.kill()
		death_tween = null

func update(delta: float):
	camera_2d.zoom = camera_2d.zoom.lerp(target_zoom, zoom_speed * delta)


func _play_death_animation() -> void:
	if not sprite_2d:
		return

	sprite_2d.stop()
	sprite_2d.z_index = 4
	var fall_direction := 1.0
	if sprite_2d.flip_h:
		fall_direction = -1.0

	death_tween = create_tween().set_parallel(true)
	death_tween.tween_property(sprite_2d, "rotation", 1.55 * fall_direction, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	death_tween.tween_property(sprite_2d, "position", sprite_2d.position + Vector2(10.0 * fall_direction, 13.0), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	death_tween.tween_property(sprite_2d, "scale", sprite_2d.scale * Vector2(1.08, 0.72), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	death_tween.tween_property(sprite_2d, "modulate", Color(1.0, 0.28, 0.22, 0.88), 0.14)
	death_tween.tween_property(sprite_2d, "modulate", Color(0.35, 0.28, 0.26, 0.55), 0.28).set_delay(0.14)


func _on_death_timer_timeout() -> void:
	var map = character.get_parent()
	if map.has_method("show_death_screen"):
		map.show_death_screen()
	else:
		map.reset_scene()
