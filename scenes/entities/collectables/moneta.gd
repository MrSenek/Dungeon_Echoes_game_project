extends RigidBody2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var graphics_settings = get_node_or_null("/root/GraphicsSettings")
	if graphics_settings:
		graphics_settings.apply_to_tree(self)
	var Throw_x = randi_range(-100,100)
	var Throw_y = randi_range(-120,-160)
	var Throw = Vector2(Throw_x, Throw_y)
	apply_central_impulse(Throw)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		PlayerData.add_coins(DifficultySettings.get_coin_reward(1))
		audio_stream_player_2d.play()
		set_collision_mask_value(1, false)
		hide()


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()


func _on_lifetime_timeout() -> void:
	queue_free()
