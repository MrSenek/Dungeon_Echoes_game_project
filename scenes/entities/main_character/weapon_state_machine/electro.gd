extends Weapon_State

class_name electro

const ATTACK_RANGE := 150.0
const ATTACK_HEIGHT := 20.0
const ATTACK_DURATION := 0.4
const BASE_COOLDOWN := 1.0
const FIRST_TARGET_VERTICAL_RANGE := 80.0
const CHAIN_RANGE := 220.0
const CHAIN_MAX_TARGETS := 4
const CHAIN_DAMAGE_MULTIPLIER := 0.65
const CHAIN_JUMP_DELAY := 0.08

@onready var lightning_line = $lightning_line
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
	weapon_cooldown.wait_time = BASE_COOLDOWN
	_hide_lightning_line()
	collision.monitoring = false
	timer_dot.stop()


func enter():
	_hide_lightning_line()
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
	_hide_lightning_line()
	collision.monitoring = false
	timer_dot.stop()
	audio_stream_player.stop()


func handle_input(event: InputEvent):
	if Input.is_action_just_pressed("strzal") and weapon_cooldown.is_stopped():
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
	var cooldown_duration := BASE_COOLDOWN * PlayerData.get_cooldown_multiplier()
	weapon_cooldown.wait_time = BASE_COOLDOWN
	weapon_cooldown.start(cooldown_duration)
	cooldown_started.emit(name, cooldown_duration)
	_update_attack_direction()
	var attack_start_position = character.global_position
	_prepare_lightning_line()
	lightning_line.create_lightning(attack_start_position, attack_start_position + Vector2(ATTACK_RANGE * last_dir, 0))
	await get_tree().physics_frame
	if current_attack_token != attack_token:
		return
	await _chain_damage_overlapping_targets(current_attack_token, attack_start_position)
	
	await get_tree().create_timer(ATTACK_DURATION).timeout
	if current_attack_token != attack_token:
		return
	_hide_lightning_line()
	attack_active = false
	collision.monitoring = false
	timer_dot.stop()
	audio_stream_player.stop()


func _on_timer_dot_timeout() -> void:
	pass


func _chain_damage_overlapping_targets(current_attack_token: int, attack_start_position: Vector2) -> void:
	var hit_targets: Array[Node2D] = []
	var first_target = _find_initial_chain_target(hit_targets)
	if not first_target:
		return

	var current_target = first_target
	var current_damage = damage * PlayerData.get_attack_multiplier()
	var lightning_points: Array[Vector2] = [attack_start_position]

	for chain_index in range(CHAIN_MAX_TARGETS):
		if current_attack_token != attack_token or not is_instance_valid(current_target):
			return

		var current_target_position = current_target.global_position
		hit_targets.append(current_target)
		current_target.get_node("HP").damage_taken(current_damage)
		lightning_points.append(current_target_position)
		lightning_line.create_chain_lightning(lightning_points)

		current_damage *= CHAIN_DAMAGE_MULTIPLIER
		if chain_index == CHAIN_MAX_TARGETS - 1:
			break

		await get_tree().create_timer(CHAIN_JUMP_DELAY).timeout
		if current_attack_token != attack_token:
			return

		current_target = _find_next_chain_target(current_target_position, hit_targets)
		if not current_target:
			break


func _find_next_chain_target(source_position: Vector2, excluded_targets: Array[Node2D]) -> Node2D:
	return _find_closest_target(get_tree().get_nodes_in_group("enemy"), source_position, excluded_targets, CHAIN_RANGE)


func _find_initial_chain_target(excluded_targets: Array[Node2D]) -> Node2D:
	var candidates: Array = collision.get_overlapping_bodies()
	for target in _get_physics_hitbox_targets():
		if not candidates.has(target):
			candidates.append(target)

	var first_target = _find_closest_target(candidates, character.global_position, excluded_targets)
	if first_target:
		return first_target

	return _find_first_chain_target(excluded_targets)


func _get_physics_hitbox_targets() -> Array:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(ATTACK_RANGE, ATTACK_HEIGHT)

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, character.global_position + Vector2((ATTACK_RANGE / 2.0) * last_dir, 0.0))
	query.collision_mask = collision.collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var targets: Array = []
	var results = character.get_world_2d().direct_space_state.intersect_shape(query, 32)
	for result in results:
		var collider = result.get("collider")
		if collider and not targets.has(collider):
			targets.append(collider)

	return targets


func _find_closest_target(targets: Array, source_position: Vector2, excluded_targets: Array[Node2D], max_distance := INF) -> Node2D:
	var closest_target: Node2D = null
	var closest_distance := max_distance
	for target in targets:
		if not _can_chain_to_target(target, excluded_targets):
			continue

		var distance = source_position.distance_to(target.global_position)
		if distance < closest_distance:
			closest_target = target
			closest_distance = distance

	return closest_target


func _can_chain_to_target(target, excluded_targets: Array[Node2D]) -> bool:
	return target is Node2D \
		and is_instance_valid(target) \
		and not target.is_in_group("Player") \
		and target.has_node("HP") \
		and not excluded_targets.has(target)


func _find_first_chain_target(excluded_targets: Array[Node2D]) -> Node2D:
	var closest_target: Node2D = null
	var closest_forward_distance := ATTACK_RANGE
	for target in get_tree().get_nodes_in_group("enemy"):
		if not _can_chain_to_target(target, excluded_targets):
			continue

		var offset = target.global_position - character.global_position
		var forward_distance = offset.x * last_dir
		if forward_distance < 0.0 or forward_distance > ATTACK_RANGE:
			continue
		if abs(offset.y) > FIRST_TARGET_VERTICAL_RANGE:
			continue
		if forward_distance < closest_forward_distance:
			closest_target = target
			closest_forward_distance = forward_distance

	return closest_target


func _update_attack_direction() -> void:
	collision.position.x = 0
	collision_shape.position.x = (ATTACK_RANGE / 2.0) * last_dir


func _prepare_lightning_line() -> void:
	lightning_line.set_as_top_level(true)
	lightning_line.global_position = Vector2.ZERO
	lightning_line.show()


func _hide_lightning_line() -> void:
	lightning_line.hide()
	lightning_line.clear_lightning()
	lightning_line.set_as_top_level(false)
	lightning_line.position = Vector2.ZERO
