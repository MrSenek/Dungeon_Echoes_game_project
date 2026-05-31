extends CharacterBody2D
const HealthDropper = preload("res://scenes/entities/collectables/health_dropper.gd")

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var timer: Timer = $Timer
@onready var dziura: RayCast2D = $RayCast2D2
@onready var bullet_scena : PackedScene = preload("res://scenes/entities/universal/weapons/SmallFireball.tscn")
@onready var shoot_cooldown: Timer = $shoot_cooldown
@onready var monetka : PackedScene = preload("res://scenes/entities/collectables/Moneta.tscn")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var stats: Stats
@export_range(0.0, 1.0, 0.01) var health_drop_chance: float = 0.12
@onready var hit_flash_timer: Timer = $hit_flash_timer


const SPEED = 75.0
const JUMP_VELOCITY = -250.0
var is_dead = false

var external_force := Vector2.ZERO

#function for external forces like push back, gravity, slow
func add_external_force(force: Vector2):
	external_force += force


func _ready() -> void:
	self.add_to_group("enemy")


func _physics_process(delta: float) -> void:
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if !is_dead:
		wandering()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	#for using external forces
	velocity += external_force
	external_force = Vector2.ZERO
	velocity = velocity.limit_length(300)
	
	move_and_slide()


func shoot():
	if shoot_cooldown.is_stopped():
		shoot_cooldown.start(3)
		for i in range(3):
			var add_bullet = bullet_scena.instantiate()
			if i != 0:
				add_bullet.get_node("PointLight2D").enabled = false
			add_bullet.global_position = global_position
			add_bullet.global_position.y += randi_range(2,5) * [-1,1].pick_random()
			add_bullet.direction = direction
			add_bullet.shooter = "enemy"
			add_bullet.damage *= stats.get_scaled_attack(PlayerData.current_round)
			get_tree().current_scene.add_child(add_bullet)
			if i < 2:
				await get_tree().create_timer(0.2).timeout



func jump():
	if  is_on_floor():
		velocity.y = JUMP_VELOCITY

var direction = 1
func edge():
	if !dziura.is_colliding() and is_on_floor():
		direction *= -1
		dziura.position.x *= -1
		ray_cast_2d.target_position.x *= -1
		timer.start(randi_range(3,8))

func wandering():
	if timer.is_stopped():
		direction = (randi() % 2) * 2 - 1
		dziura.position.x = abs(dziura.position.x) * direction
		ray_cast_2d.target_position.x = abs(ray_cast_2d.target_position.x) * direction
		timer.start()
	velocity.x = move_toward(velocity.x, direction*SPEED, 200)
	edge()
	shoot()
	if  ray_cast_2d.is_colliding():
		jump()




func _on_hp_death() -> void:

	if is_dead:
		return
	else:
		animated_sprite_2d.play("dead")
		is_dead = true
		collision_layer = 0
		collision_layer = 0
		await get_tree().create_timer(2).timeout
		var moneta = monetka.instantiate()
		moneta.global_position = global_position
		get_tree().current_scene.add_child(moneta)
		HealthDropper.try_drop(global_position, health_drop_chance)
		queue_free()
