extends RigidBody2D

@export var blackhole: PackedScene
@export var flight_time := 1.0
@export var collapse_delay := 0.5

var dir: int = 1
var _age := 0.0
var _collapse_progress := 0.0
var _visual_root: Node2D
var _core: Sprite2D
var _aura: Sprite2D
var _trail: Line2D
var _trail_points: Array[Vector2] = []

static var _aura_texture: GradientTexture2D
static var _core_texture: GradientTexture2D
static var _additive_material: CanvasItemMaterial

func _ready() -> void:
	_setup_visuals()
	var throw_x = 300 * dir
	var throw_y = -250
	var throw_dir = Vector2(throw_x, throw_y)
	apply_central_impulse(throw_dir)
	await get_tree().create_timer(flight_time).timeout
	freeze = true
	_start_collapse()
	await get_tree().create_timer(collapse_delay).timeout
	var black_hole = blackhole.instantiate()
	black_hole.global_position = global_position
	get_tree().current_scene.add_child(black_hole)
	queue_free()


func _process(delta: float) -> void:
	_age += delta
	if not _visual_root:
		return

	var pulse = 1.0 + sin(_age * 14.0) * 0.08
	var core_size = lerp(0.34 * pulse, 0.16, _collapse_progress)
	var aura_size = lerp(0.95 * (1.0 + sin(_age * 9.0) * 0.06), 1.45, _collapse_progress)
	_core.scale = Vector2.ONE * core_size
	_aura.scale = Vector2.ONE * aura_size
	_update_trail()


func _setup_visuals() -> void:
	var original_sprite = get_node_or_null("Sprite2D")
	if original_sprite:
		original_sprite.visible = false

	_visual_root = Node2D.new()
	_visual_root.name = "GravityGrenadeVisual"
	add_child(_visual_root)

	_aura = _make_sprite(
		_get_aura_texture(),
		Vector2.ONE * 0.95
	)
	_visual_root.add_child(_aura)

	_core = _make_sprite(
		_get_core_texture(),
		Vector2.ONE * 0.34
	)
	_visual_root.add_child(_core)

	_trail = Line2D.new()
	_trail.name = "GravityTrail"
	_trail.top_level = true
	_trail.global_position = Vector2.ZERO
	_trail.width = 9.0
	_trail.default_color = Color(0.28, 0.86, 1.0, 0.55)
	var trail_gradient = Gradient.new()
	trail_gradient.offsets = PackedFloat32Array([0.0, 1.0])
	trail_gradient.colors = PackedColorArray([
		Color(0.58, 0.98, 1.0, 0.75),
		Color(0.38, 0.08, 1.0, 0.0)
	])
	_trail.gradient = trail_gradient
	_trail.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(_trail)


func _start_collapse() -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "_collapse_progress", 1.0, collapse_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_aura, "modulate:a", 0.0, collapse_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(_core, "modulate", Color(0.0, 0.0, 0.0, 1.0), collapse_delay * 0.85)
	tween.tween_property(_trail, "modulate:a", 0.0, collapse_delay * 0.8)


func _update_trail() -> void:
	_trail_points.push_front(global_position)
	if _trail_points.size() > 12:
		_trail_points.pop_back()

	_trail.clear_points()
	for i in range(_trail_points.size()):
		_trail.add_point(_trail_points[i])


func _make_sprite(texture: Texture2D, sprite_scale: Vector2) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.texture = texture
	sprite.scale = sprite_scale
	sprite.material = _get_additive_material()
	return sprite


func _get_aura_texture() -> GradientTexture2D:
	if _aura_texture == null:
		_aura_texture = _make_radial_texture(Color(0.42, 0.88, 1.0, 0.65), Color(0.32, 0.05, 0.95, 0.0), 96)
	return _aura_texture


func _get_core_texture() -> GradientTexture2D:
	if _core_texture == null:
		_core_texture = _make_radial_texture(Color(0.95, 1.0, 1.0, 1.0), Color(0.08, 0.0, 0.28, 0.0), 64)
	return _core_texture


func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = _make_additive_material()
	return _additive_material


func _make_radial_texture(center_color: Color, edge_color: Color, size: int) -> GradientTexture2D:
	var gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	gradient.colors = PackedColorArray([
		center_color,
		center_color.lerp(edge_color, 0.45),
		edge_color
	])

	var texture = GradientTexture2D.new()
	texture.width = size
	texture.height = size
	texture.fill = 1
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.95, 0.5)
	texture.gradient = gradient
	return texture


func _make_additive_material() -> CanvasItemMaterial:
	var material = CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return material
