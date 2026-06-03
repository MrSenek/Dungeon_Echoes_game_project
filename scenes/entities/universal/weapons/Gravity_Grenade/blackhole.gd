extends Area2D

@export var pull_strength: float = 1550.0
@export var life_time: float = 4.2
@export var inner_radius: float = 28.0
@export var outer_speed_limit: float = 210.0
@export var inner_speed_limit: float = 65.0
@export var direct_pull_step: float = 42.0
@export var implosion_base_damage: float = 18.0
@export var implosion_damage_per_capture: float = 4.0
@export var implosion_max_bonus_damage: float = 24.0
@export var implosion_damage_radius: float = 105.0
@export var combo_support_min_captures: int = 2

var _age: float = 0.0
var _core: Sprite2D
var _halo: Sprite2D
var _particles: GPUParticles2D
var _dying: bool = false
var _birth: float = 0.0
var _captured_enemies: Array[Node2D] = []
var _imploded: bool = false

static var _halo_texture: GradientTexture2D
static var _core_texture: GradientTexture2D
static var _additive_material: CanvasItemMaterial
static var _implosion_ring_points: PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	monitoring = true
	gravity_space_override = Area2D.SPACE_OVERRIDE_COMBINE
	gravity_point = true
	gravity_point_unit_distance = 100
	gravity = 1000
	_setup_visuals()
	
	await get_tree().create_timer(max(life_time - 0.35, 0.1)).timeout
	_collapse_out()
	await get_tree().create_timer(0.35).timeout
	queue_free()


func _process(delta: float) -> void:
	_age += delta
	if not _core or not _halo:
		return

	_birth = min(_birth + delta * 4.5, 1.0)
	var birth_ease = 1.0 - pow(1.0 - _birth, 3.0)
	if _dying:
		return

	_core.scale = Vector2.ONE * (1.15 + sin(_age * 8.0) * 0.035) * birth_ease
	_halo.scale = Vector2.ONE * (1.95 + sin(_age * 3.0) * 0.08) * birth_ease


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and body is Node2D:
			var enemy: Node2D = body as Node2D
			_capture_enemy(enemy)
			_pull_enemy(enemy, delta)


func _capture_enemy(enemy: Node2D) -> void:
	if not _captured_enemies.has(enemy):
		_captured_enemies.append(enemy)


func _pull_enemy(enemy: Node2D, delta: float) -> void:
	if not is_instance_valid(enemy):
		return

	var dir: Vector2 = global_position - enemy.global_position
	var dist: float = dir.length()
	if dist < 6.0:
		return

	var pull_direction: Vector2 = dir.normalized()
	var center_factor: float = clamp(1.0 - dist / 90.0, 0.0, 1.0)
	var strength: float = (pull_strength / max(dist, 42.0)) * lerp(1.0, 1.65, center_factor)
	var force: Vector2 = pull_direction * strength

	if enemy.has_method("add_external_force"):
		enemy.add_external_force(force)

	if enemy is CharacterBody2D:
		var character_body: CharacterBody2D = enemy as CharacterBody2D
		character_body.velocity += force * delta * 10.0
		var speed_limit: float = lerp(outer_speed_limit, inner_speed_limit, center_factor)
		character_body.velocity = character_body.velocity.limit_length(speed_limit)

	var step: float = direct_pull_step * delta * lerp(0.55, 1.35, center_factor)
	if dist > inner_radius:
		enemy.global_position = enemy.global_position.move_toward(global_position, step)


func _setup_visuals() -> void:
	_particles = get_node_or_null("GPUParticles2D")
	if _particles:
		_particles.amount = 90
		_particles.lifetime = 1.15
		_particles.speed_scale = 1.25
		_particles.fixed_fps = 30
		_particles.emitting = true

	var old_glow = get_node_or_null("Sprite2D2")
	if old_glow:
		old_glow.visible = false

	var old_core = get_node_or_null("Sprite2D")
	if old_core:
		old_core.visible = false

	_halo = _make_sprite(
		_get_halo_texture(),
		Vector2.ONE * 1.95,
		true
	)
	_halo.z_index = -2
	add_child(_halo)

	_core = _make_sprite(
		_get_core_texture(),
		Vector2.ONE * 1.15,
		false
	)
	_core.z_index = 3
	add_child(_core)

	_halo.scale = Vector2.ZERO
	_core.scale = Vector2.ZERO


func _collapse_out() -> void:
	_dying = true
	_implode()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(_halo, "modulate:a", 0.0, 0.35)
	tween.tween_property(_core, "modulate:a", 0.0, 0.35)
	tween.tween_property(_core, "scale", Vector2.ONE * 0.2, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_play_implosion_ring()


func _implode() -> void:
	if _imploded:
		return
	_imploded = true

	var valid_targets: Array[Node2D] = []
	for enemy in _captured_enemies:
		if not is_instance_valid(enemy) or not enemy.has_node("HP"):
			continue
		var in_damage_radius: bool = enemy.global_position.distance_to(global_position) <= implosion_damage_radius
		if in_damage_radius:
			valid_targets.append(enemy)

	if valid_targets.is_empty():
		return

	var bonus_damage: float = min(float(valid_targets.size()) * implosion_damage_per_capture, implosion_max_bonus_damage)
	var damage: float = (implosion_base_damage + bonus_damage) * PlayerData.get_attack_multiplier()

	for enemy in valid_targets:
		enemy.set_meta("combo_source", "gravity_grenade")
		enemy.get_node("HP").damage_taken(damage)
		_push_enemy_from_center(enemy)

	_support_combo(valid_targets.size())


func _push_enemy_from_center(enemy: Node2D) -> void:
	if not is_instance_valid(enemy):
		return

	var dir: Vector2 = enemy.global_position - global_position
	if dir.length() <= 0.1:
		dir = Vector2.RIGHT.rotated(randf() * TAU)
	var impulse: Vector2 = dir.normalized() * 90.0

	if enemy.has_method("add_external_force"):
		enemy.add_external_force(impulse)
	if enemy is CharacterBody2D:
		var character_body: CharacterBody2D = enemy as CharacterBody2D
		character_body.velocity += impulse


func _support_combo(captured_count: int) -> void:
	if captured_count < combo_support_min_captures or PlayerData.combo_count <= 0:
		return

	PlayerData.combo_time_left = max(PlayerData.combo_time_left, PlayerData.COMBO_WINDOW * 0.75)


func _play_implosion_ring() -> void:
	var ring: Line2D = Line2D.new()
	ring.width = 4.0
	ring.default_color = Color(0.58, 0.92, 1.0, 0.9)
	ring.points = _get_implosion_ring_points()
	ring.z_index = 4
	add_child(ring)

	var tween: Tween = ring.create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector2.ONE * 5.6, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(ring.queue_free).set_delay(0.3)


func _make_circle_points(radius: float, segments: int) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(segments):
		var angle: float = TAU * float(i) / float(segments)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	if points.size() > 0:
		points.append(points[0])
	return points


func _make_sprite(texture: Texture2D, sprite_scale: Vector2, additive: bool) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.texture = texture
	sprite.scale = sprite_scale
	if additive:
		sprite.material = _get_additive_material()
	return sprite


func _get_halo_texture() -> GradientTexture2D:
	if _halo_texture == null:
		_halo_texture = _make_radial_texture(Color(0.16, 0.68, 1.0, 0.32), Color(0.15, 0.0, 0.38, 0.0), 160)
	return _halo_texture


func _get_core_texture() -> GradientTexture2D:
	if _core_texture == null:
		_core_texture = _make_radial_texture(Color(0.0, 0.0, 0.0, 1.0), Color(0.06, 0.0, 0.18, 0.0), 96)
	return _core_texture


func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = _make_additive_material()
	return _additive_material


func _get_implosion_ring_points() -> PackedVector2Array:
	if _implosion_ring_points.is_empty():
		_implosion_ring_points = _make_circle_points(12.0, 30)
	return _implosion_ring_points


func _make_radial_texture(center_color: Color, edge_color: Color, size: int) -> GradientTexture2D:
	var gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	gradient.colors = PackedColorArray([
		center_color,
		center_color.lerp(edge_color, 0.35),
		edge_color
	])

	var texture = GradientTexture2D.new()
	texture.width = size
	texture.height = size
	texture.fill = 1
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.96, 0.5)
	texture.gradient = gradient
	return texture


func _make_additive_material() -> CanvasItemMaterial:
	var material = CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return material
