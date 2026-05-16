extends Area2D
const SPEED = 200
var direction = 1
@export var damage = 50
const cooldown = 0.5
var shooter = ""
@onready var point_light_2d: PointLight2D = $PointLight2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D



func _ready() -> void:
	get_tree().create_timer(5.0).timeout.connect(queue_free)
	if direction < 0:
		sprite_2d.flip_h = true
		collision_shape_2d.position.x *= -1
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += direction*SPEED*delta
	

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(shooter):
		if body.has_node("HP"):
			body.get_node("HP").damage_taken(damage)
		queue_free()
	
