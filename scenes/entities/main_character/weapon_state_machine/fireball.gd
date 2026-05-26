extends Weapon_State
class_name fireball

@onready var bullet_scena : PackedScene = preload("res://scenes/entities/universal/weapons/fireball.tscn")
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var weapon_cooldown: Timer = $weapon_cooldown

signal weapon_fired(recoil_strength)
signal cooldown_started(weapon_name: String, duration: float)

func enter():
	if not is_node_ready():
		await tree_entered
	sprite_2d.show()

func exit():
	sprite_2d.hide()

func update(_delta):
	
	if character.sprite_2d.flip_h:
		sprite_2d.position.x = 15
		sprite_2d.flip_h = false
		sprite_2d.rotation = (-PI / 2)

	else:
		sprite_2d.position.x = -15
		sprite_2d.flip_h = true
		sprite_2d.rotation = (PI / 2)

# Direction tracking and cooldown state
var last_dir: int = 1
var can_shoot: bool = true

func handle_input(event: InputEvent) -> void:
	var input_dir = Input.get_axis("left", "right")
	if input_dir != 0:
		last_dir = input_dir

	if event.is_action_pressed("strzal") and can_shoot:
		shoot()

func shoot() -> void:
	# Prevent rapid firing by starting the cooldown immediately
	can_shoot = false
	cooldown_started.emit(name, weapon_cooldown.wait_time)
	# Emit signal to trigger player recoil
	weapon_fired.emit(300)
	
	# Instantiate the projectile from the preloaded scene
	var projectile = bullet_scena.instantiate()
	
	# Get cooldown duration from the projectile (fallback to 0.5s if not defined)
	var cooldown_duration = projectile.cooldown if "cooldown" in projectile else 0.5
	
	# Set projectile's initial properties
	projectile.global_position = character.global_position
	projectile.direction = last_dir
	projectile.shooter = "Player"

	# Apply player's attack stats to projectile damage
	if "damage" in projectile:
		projectile.damage *= PlayerData.attack

	# Add the projectile to the main scene tree so it moves independently of the player
	get_tree().current_scene.add_child(projectile)

	weapon_cooldown.start(cooldown_duration)



func _on_weapon_cooldown_timeout() -> void:
	can_shoot = true
