extends Weapon_State

class_name electro
@onready var lightning_line: Line2D = $lightning_line
@onready var collision: Area2D = $Area2D
@onready var timer_dot: Timer = $Area2D/timer_DOT
@export var damage: float

var last_dir = 1
func enter():
	collision.monitoring = false
	
func exit():
	pass

func handle_input(event: InputEvent):
	if Input.is_action_just_pressed("strzal"):
		attack()
		
func update(delta: float):
	var direction := Input.get_axis("left","right")
	if direction:
		if direction > 0:
			last_dir = 1
			collision.position.x = abs(collision.position.x) * direction
		elif direction < 0:
			last_dir = -1
			collision.position.x = abs(collision.position.x) * direction
		

func attack():
	collision.monitoring = true
	timer_dot.start()
	var target_pos = Vector2(150*last_dir,0)
	lightning_line.show()
	lightning_line.create_lightning(Vector2.ZERO, target_pos)
	
	await get_tree().create_timer(0.2).timeout
	lightning_line.hide()
	collision.monitoring = false
	timer_dot.stop()


func _on_timer_dot_timeout() -> void:
	var targets = collision.get_overlapping_bodies()
	for body in targets:
		if body.has_node("HP"):
			body.get_node("HP").damage_taken(damage*PlayerData.attack)
