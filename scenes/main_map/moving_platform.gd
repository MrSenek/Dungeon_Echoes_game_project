extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shape_cast_2d: ShapeCast2D = $AnimatableBody2D/ShapeCast2D

signal platform_first_used()

var first_used: bool = false
var is_on_top: bool = false
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interaction") and shape_cast_2d.is_colliding():
		if is_on_top:
			animation_player.play_backwards("moving_platform_up")
		else:
			animation_player.play("moving_platform_up")
		is_on_top = !is_on_top
		if !first_used:
			platform_first_used.emit()
		first_used = true
		
