extends Weapon_State

class_name electro

const ATTACK_RANGE := 150.0
const ATTACK_HEIGHT := 20.0
const ATTACK_DURATION := 0.4

@onready var lightning_line: Line2D = $lightning_line
@onready var collision: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var timer_dot: Timer = $Area2D/timer_DOT
@export var damage: float
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var weapon_cooldown: Timer = $weapon_cooldown

signal cooldown_started(weapon_name: String, duration: float)

var direction
var last_dir = 1
var attack_active := false
var attack_token := 0


func _ready():
	if collision_shape.shape is RectangleShape2D:
		collision_shape.shape = collision_shape.shape.duplicate()
		collision_shape.shape.size = Vector2(ATTACK_RANGE, ATTACK_HEIGHT)
	lightning_line.hide()
	collision.monitoring = false
	timer_dot.stop()


func enter():
	lightning_line.hide()
	lightning_line.clear_points()
	collision.monitoring = false
	timer_dot.stop()
	direction = character.dir
	if direction:
		if direction > 0:
			last_dir = 1
		elif direction < 0:
			last_dir = -1
	_update_attack_direction()


func exit():
	attack_token += 1
	attack_active = false
	lightning_line.hide()
	lightning_line.clear_points()
	collision.monitoring = false
	timer_dot.stop()
	audio_stream_player.stop()


func handle_input(event: InputEvent):
	if Input.is_action_just_pressed("strzal") and weapon_cooldown.is_stopped():
		weapon_cooldown.start()
		attack()
		
func update(_delta: float):
	if attack_active:
		return
	direction = Input.get_axis("left","right")
	if direction:
		if direction > 0:
			last_dir = 1
		elif direction < 0:
			last_dir = -1
		_update_attack_direction()
		

func attack():
	attack_token += 1
	var current_attack_token = attack_token
	attack_active = true
	audio_stream_player.play()
	collision.monitoring = true
	cooldown_started.emit(name, weapon_cooldown.wait_time)
	timer_dot.start()
	_update_attack_direction()
	var target_pos = Vector2(ATTACK_RANGE * last_dir, 0)
	lightning_line.show()
	lightning_line.create_lightning(Vector2.ZERO, target_pos)
	await get_tree().physics_frame
	if current_attack_token != attack_token:
		return
	_damage_overlapping_targets()
	
	await get_tree().create_timer(ATTACK_DURATION).timeout
	if current_attack_token != attack_token:
		return
	lightning_line.hide()
	lightning_line.clear_points()
	attack_active = false
	collision.monitoring = false
	timer_dot.stop()
	audio_stream_player.stop()


func _on_timer_dot_timeout() -> void:
	if attack_active:
		_damage_overlapping_targets()


func _damage_overlapping_targets() -> void:
	var targets = collision.get_overlapping_bodies()
	for body in targets:
		if body.has_node("HP"):
			body.get_node("HP").damage_taken(damage * PlayerData.get_attack_multiplier())


func _update_attack_direction() -> void:
	collision.position.x = 0
	collision_shape.position.x = (ATTACK_RANGE / 2.0) * last_dir
