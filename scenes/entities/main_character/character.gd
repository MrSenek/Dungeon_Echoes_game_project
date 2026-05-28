extends CharacterBody2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var HEALTH_POINTS: int = PlayerData.max_health
@onready var camera_2d: Camera2D = $Camera2D
@onready var low_hp_indicator: Sprite2D = $low_hp_indicator
@onready var heart_beat: AudioStreamPlayer = $heart_beat
@onready var hud = $HUD
@onready var weapon_state_machine: Weapon_State_Machine = $weapon_state_machine



const SPEED = 250.0
const JUMP_VELOCITY = -400.0

var SPAWN_POINT
var dir
var speed_modifier: float = 1.0
var is_alive: bool = true
var trauma = 0.0
var max_shake = 8.0
var low_hp_active := false

func _ready() -> void:
	PlayerData.crit_happened.connect(on_crit)
	SPAWN_POINT = global_position
	self.add_to_group("Player")
	camera_2d.enabled = true
	camera_2d.make_current()
	dir = sprite_2d.flip_h
	weapon_state_machine.weapon_cooldown_started.connect(hud.show_cooldown)
	weapon_state_machine.weapon_selected.connect(hud.set_selected_weapon)
	if weapon_state_machine.current_state:
		hud.set_selected_weapon(weapon_state_machine.current_state.name)

func _process(delta: float) -> void:
	if Input.get_axis("left","right") != 0:
		dir = Input.get_axis("left", "right")
	
	var hp = get_node("HP")
	var health_percent = float(hp.CURRENT_HEALTH) / float(hp.MAX_HEALTH)

	if health_percent <= 0.4 and not low_hp_active:
		heart_beat.play()
		Engine.time_scale = 0.8
		low_hp_active = true
		low_hp_effect()

	if health_percent > 0.4 and low_hp_active:
		heart_beat.stop()
		Engine.time_scale = 1
		low_hp_active = false
		stop_low_hp_effect()
	
	update_camera_shake(delta)


func change_speed(new: float):
	speed_modifier = new


func _on_hp_death() -> void:
	is_alive = false
	
func update_camera_shake(delta):
	# trauma powoli maleje
	trauma = max(trauma - delta * 2.5, 0.0)

	# trauma² daje bardziej naturalny efekt
	var amount = trauma * trauma

	camera_2d.offset = Vector2(
		randf_range(-max_shake, max_shake) * amount,
		randf_range(-max_shake, max_shake) * amount
	)


func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
func on_crit():
	add_trauma(0.7)

var low_hp_tween: Tween

func low_hp_effect():
	low_hp_indicator.visible = true
	
	var grad = low_hp_indicator.texture.gradient

	if low_hp_tween:
		low_hp_tween.kill()
		low_hp_tween = null

	low_hp_tween = create_tween()
	low_hp_tween.set_loops()

	low_hp_tween.tween_method(
		func(value):
			grad.set_offset(1, value),
		0.7,
		0.9,
		0.8
	)

	low_hp_tween.tween_method(
		func(value):
			grad.set_offset(1, value),
		0.9,
		0.7,
		0.8
	)

func stop_low_hp_effect():
	if low_hp_tween:
		low_hp_tween.kill()
		low_hp_tween = null

	low_hp_indicator.visible = false
