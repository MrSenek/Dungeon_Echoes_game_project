extends Enemy_State
@onready var jump_collider: RayCast2D = $jump_collider
@onready var edge_detection: RayCast2D = $edge_detection
@onready var sprite_2d: AnimatedSprite2D = $"../../Sprite2D"
@onready var random_timer: Timer = $random_timer

var jump_velocity = 145.8
var blob_wander_speed = 100.0

@warning_ignore("unused_parameter")
func enter(data = {}):
	var direction = character.dir
	jump_collider.target_position.x = abs(jump_collider.target_position.x) * direction
	edge_detection.position.x = abs(edge_detection.position.x) * direction
	edge_detection.target_position.x = abs(edge_detection.target_position.x) * direction
	random_timer.start(randi_range(3,9))


@warning_ignore("unused_parameter")
func update(delta: float):
	if character.can_see:
		enemy_state_machine.change_state("alert_state")

func physics_update(delta: float):
	jump_detect()
	is_at_edge()
	wander(delta)

	character.move_and_slide()

func wander(delta: float):
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	character.velocity.x = blob_wander_speed * character.dir


func jump_detect():
	if jump_collider.is_colliding() and character.is_on_floor():
		character.velocity.y = -jump_velocity

func is_at_edge():
	if !edge_detection.is_colliding() and character.is_on_floor():
		turn_around()

func turn_around():
		jump_collider.target_position.x *= -1
		edge_detection.position.x *= -1
		edge_detection.target_position.x *= -1 
		sprite_2d.flip_h = not sprite_2d.flip_h

func _on_random_timer_timeout() -> void:
	random_timer.start(randi_range(3,8))
	var turn:bool = randi() % 2 == 0
	if turn:
		turn_around()
