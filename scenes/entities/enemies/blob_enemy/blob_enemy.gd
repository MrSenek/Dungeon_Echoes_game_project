extends CharacterBody2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var eyes: RayCast2D = $detecting_player/eyes
@export var stats: Stats

var player_in_range: CharacterBody2D = null
var can_see: bool = false
var dir: int = 1



func _process(_delta: float) -> void:
	player_detection()
	

func _physics_process(delta: float) -> void:
	dir = -1 if sprite_2d.flip_h else 1


func _on_detection_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = body


func _on_detection_range_body_exited(body: Node2D) -> void:
	if player_in_range == body:
		player_in_range = null

func player_detection():
	if player_in_range != null:
		eyes.target_position = to_local(player_in_range.global_position)
		
		var collider = eyes.get_collider()
		if collider and collider.is_in_group("Player"):
			can_see = true
		else:
			can_see = false
	else:
		can_see = false
