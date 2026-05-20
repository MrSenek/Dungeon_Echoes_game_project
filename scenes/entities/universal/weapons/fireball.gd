extends Area2D
@export var SPEED = 200
@export var damage = 45
@export var cooldown = 1
var shooter = ""
var direction = 1
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var hitstop: Timer = $hitstop


func _ready() -> void:
	get_tree().create_timer(5.0).timeout.connect(queue_free)
	if direction < 0:
		sprite_2d.flip_h = true
		collision_shape_2d.position.x *= -1
	audio_stream_player_2d.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += direction*SPEED*delta


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(shooter):
		if body.has_node("HP"):
			body.get_node("HP").damage_taken(damage)
			Engine.time_scale = 0.1
			hide()
			hitstop.start()


func _on_hitstop_timeout() -> void:
	Engine.time_scale = 1
	queue_free()
