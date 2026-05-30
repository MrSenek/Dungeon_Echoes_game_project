extends Area2D

@export var pull_strength := 1200.0
@export var life_time := 5.0

var _age := 0.0
var _core: Sprite2D
var _halo: Sprite2D
var _particles: GPUParticles2D
var _dying := false
var _birth := 0.0

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


func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("add_external_force"):

			var dir = global_position - body.global_position
			var dist = dir.length()

			if dist < 10:
				continue

			var strength = pull_strength / max(dist, 50)
			var force = dir.normalized() * strength

			body.add_external_force(force)

			if body is CharacterBody2D:
				body.velocity = body.velocity.limit_length(250)


func _setup_visuals() -> void:
	_particles = get_node_or_null("GPUParticles2D")
	if _particles:
		_particles.amount = 150
		_particles.lifetime = 1.15
		_particles.speed_scale = 1.25
		_particles.emitting = true

	var old_glow = get_node_or_null("Sprite2D2")
	if old_glow:
		old_glow.visible = false

	var old_core = get_node_or_null("Sprite2D")
	if old_core:
		old_core.visible = false

	_halo = _make_sprite(
		_make_radial_texture(
			Color(0.16, 0.68, 1.0, 0.32),
			Color(0.15, 0.0, 0.38, 0.0),
			160
		),
		Vector2.ONE * 1.95,
		true
	)
	_halo.z_index = -2
	add_child(_halo)

	_core = _make_sprite(
		_make_radial_texture(
			Color(0.0, 0.0, 0.0, 1.0),
			Color(0.06, 0.0, 0.18, 0.0),
			96
		),
		Vector2.ONE * 1.15,
		false
	)
	_core.z_index = 3
	add_child(_core)

	_halo.scale = Vector2.ZERO
	_core.scale = Vector2.ZERO


func _collapse_out() -> void:
	_dying = true
	var tween = create_tween().set_parallel(true)
	tween.tween_property(_halo, "modulate:a", 0.0, 0.35)
	tween.tween_property(_core, "modulate:a", 0.0, 0.35)
	tween.tween_property(_core, "scale", Vector2.ONE * 0.2, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _make_sprite(texture: Texture2D, sprite_scale: Vector2, additive: bool) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.texture = texture
	sprite.scale = sprite_scale
	if additive:
		sprite.material = _make_additive_material()
	return sprite


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
