extends CharacterBody2D


@onready var direct_detection: RayCast2D = $player_detection/direct_detection
@export var stats: Stats
@export var DMG: float = 15

var is_alive: bool = true
var dir: int = -1
var external_force := Vector2.ZERO
var gravity_pull_velocity := Vector2.ZERO

var player_dir: int
var player: CharacterBody2D = null
var player_detected: bool = false
var player_in_range: bool = false
var player_in_attack_range:bool = false

func _ready() -> void:
	DMG *= stats.get_scaled_attack(PlayerData.current_round)


func add_external_force(force: Vector2) -> void:
	if is_alive:
		external_force += force


func apply_movement_with_external_force(max_speed := 300.0) -> void:
	gravity_pull_velocity += external_force
	external_force = Vector2.ZERO
	gravity_pull_velocity = gravity_pull_velocity.limit_length(250)
	velocity += gravity_pull_velocity
	velocity = velocity.limit_length(max_speed)
	move_and_slide()
	gravity_pull_velocity = gravity_pull_velocity.move_toward(Vector2.ZERO, 900 * get_physics_process_delta_time())

func _process(delta: float) -> void:
	if player and player_detected:
		direct_detection.target_position = to_local(player.global_position)
	if direct_detection.is_colliding():
		var collider = direct_detection.get_collider()
		if collider and collider.is_in_group("Player") and player and player_detected:
			player_in_range = true
			player_dir = sign(player.global_position.x - global_position.x)
		else:
			player_in_range = false
	else:
		player_in_range = false
	

func _on_detection_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_detected = true

func _on_detection_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
		player_detected = false
		player_in_range = false
