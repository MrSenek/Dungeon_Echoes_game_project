extends Area2D
var closest_enemy = null
var speed = 300
var shooter
var sending_time = 0.2
var current_time = 0
@export var explosion: PackedScene
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@export var damage: int = 75
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitstop: Timer = $hitstop
@export var crit_chance: float
@export var crit_text: PackedScene



func _ready() -> void:
	hitstop.ignore_time_scale = true
	audio_stream_player_2d.play()
	closest_enemy = find_enemy()
	if closest_enemy == null:
		queue_free()

func _physics_process(delta: float) -> void:
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if not collider.is_in_group(str(shooter)):
			explode_self()
			return

	if current_time < sending_time:
		global_position.y -= delta * 400
		current_time += delta
		rotation = deg_to_rad(-90)
		return

	if not is_instance_valid(closest_enemy):
		closest_enemy = find_enemy()
		

	if not is_instance_valid(closest_enemy):
		var velocity = Vector2.RIGHT.rotated(rotation) * speed
		global_position += velocity * delta
	else:
		chase_enemy(delta)


func explode_self():
	var explode = explosion.instantiate()
	explode.global_position = global_position
	get_tree().current_scene.add_child.call_deferred(explode)
	queue_free()

func hit_enemy() -> void:
	var explode = explosion.instantiate()
	explode.global_position = global_position
	get_tree().current_scene.add_child(explode)

	hide()
	collision_shape_2d.set_deferred("disabled", true)
	hitstop.start()


func find_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest_distance = INF
	var closest
	
	for enemy in enemies:
		if not enemy:
			return
		var dist = global_position.distance_to(enemy.global_position)
		
		if dist < closest_distance:
			closest_distance = dist
			closest = enemy
	return closest
		
func chase_enemy(delta: float):
	if closest_enemy == null:
		return
	var direction = (closest_enemy.global_position - global_position).normalized()
	var target_angle = direction.angle()
	rotation = rotate_toward(rotation, target_angle, 4.0 * delta)
	var velocity = Vector2.RIGHT.rotated(rotation) * speed
	global_position += velocity * delta



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
		else:
			explode_self()

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
