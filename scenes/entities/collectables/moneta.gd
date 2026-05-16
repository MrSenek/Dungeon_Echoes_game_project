extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var Throw_x = randi_range(-100,100)
	var Throw_y = randi_range(-120,-160)
	var Throw = Vector2(Throw_x, Throw_y)
	apply_central_impulse(Throw)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		PlayerData.player_coins+=1
		queue_free()
