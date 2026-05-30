extends TextureButton

@export var hover_scale := Vector2(1.07, 1.07)
@export var press_scale := Vector2(0.94, 0.94)
@export var hover_modulate := Color(1.18, 1.12, 0.92, 1.0)
@export var normal_modulate := Color.WHITE
@export var transition_time := 0.12
@export var idle_float_strength := 0.018
@export var idle_float_speed := 2.6

var _tween: Tween
var _base_scale := Vector2.ONE
var _idle_time := 0.0
var _is_hovered := false
var _is_pressed := false


func _ready() -> void:
	_base_scale = scale
	pivot_offset = size * 0.5
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)


func _process(delta: float) -> void:
	if _is_pressed:
		return

	_idle_time += delta * idle_float_speed
	var pulse := 1.0 + sin(_idle_time) * idle_float_strength
	if _is_hovered:
		scale = _base_scale * hover_scale * pulse


func _on_mouse_entered() -> void:
	_is_hovered = true
	_animate_to(_base_scale * hover_scale, hover_modulate)


func _on_mouse_exited() -> void:
	_is_hovered = false
	_is_pressed = false
	_animate_to(_base_scale, normal_modulate)


func _on_button_down() -> void:
	_is_pressed = true
	_animate_to(_base_scale * press_scale, Color(0.95, 0.88, 0.78, 1.0), transition_time * 0.65)


func _on_button_up() -> void:
	_is_pressed = false
	if _is_hovered:
		_animate_to(_base_scale * hover_scale, hover_modulate)
	else:
		_animate_to(_base_scale, normal_modulate)


func _on_focus_entered() -> void:
	_on_mouse_entered()


func _on_focus_exited() -> void:
	_on_mouse_exited()


func _animate_to(target_scale: Vector2, target_modulate: Color, duration := -1.0) -> void:
	if _tween:
		_tween.kill()

	if duration < 0.0:
		duration = transition_time

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", target_scale, duration)
	_tween.tween_property(self, "modulate", target_modulate, duration)
