extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_timer: Timer = $life_timer
@onready var damage_timer: Timer = $damage_timer


var lifetime_end: bool = false
var last_frame_played: bool = false

func _ready() -> void:
	life_timer.start()
	animated_sprite_2d.frame = randi_range(0,18)
	animated_sprite_2d.sprite_frames.set_animation_loop("default", true)

func _on_life_timer_timeout() -> void:
	animated_sprite_2d.sprite_frames.set_animation_loop("default", false)
	lifetime_end = true


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_node("HP"):
		body.get_node("HP").damage_taken(10)
		damage_timer.start()
		if body.has_method("change_speed"):
			body.change_speed(0.5)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		damage_timer.stop()
		if body.has_method("change_speed"):
			body.change_speed(1.0)


func _on_damage_timer_timeout() -> void:
	var targets = get_overlapping_bodies()
	for target in targets:
		if target.is_in_group("Player") and target.has_node("HP"):
			target.get_node("HP").damage_taken(8) # DOT może być mniejszy niż initial
