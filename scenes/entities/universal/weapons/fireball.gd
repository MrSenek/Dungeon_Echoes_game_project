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
@export var explosion: PackedScene
@export var crit_chance: float
@export var crit_text: PackedScene




func _ready() -> void:
	hitstop.ignore_time_scale = true
	var graphics_settings = get_node_or_null("/root/GraphicsSettings")
	if graphics_settings:
		graphics_settings.apply_to_tree(self)
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
			if roll_crit():
				PlayerData.crit_happened.emit()
				show_crit_text()
				body.get_node("HP").damage_taken(damage * 1.5)
				Engine.time_scale = 0.1
			else:
				body.get_node("HP").damage_taken(damage)

			call_deferred("hit_enemy")

func hit_enemy() -> void:
	var explode = explosion.instantiate()
	explode.global_position = global_position
	get_tree().current_scene.add_child(explode)

	hide()
	collision_shape_2d.set_deferred("disabled", true)
	hitstop.start()


func _on_hitstop_timeout() -> void:
	Engine.time_scale = 1
	queue_free()


func _exit_tree() -> void:
	if Engine.time_scale == 0.1:
		Engine.time_scale = 1
	
func roll_crit() -> bool:
	return randf() < crit_chance

func show_crit_text():
	var text = crit_text.instantiate()
	text.global_position = global_position
	get_tree().current_scene.add_child(text)
