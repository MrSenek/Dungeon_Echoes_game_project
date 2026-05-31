extends CanvasLayer

@onready var hint_panel: PanelContainer = $hint_panel
@onready var icon_label: Label = $hint_panel/MarginContainer/HBoxContainer/Icon_Label
@onready var hint_label: Label = $hint_panel/MarginContainer/HBoxContainer/Hint_Label

var hide_tween: Tween
var visible_tween: Tween


func _ready() -> void:
	layer = 20
	visible = true
	hint_panel.visible = false
	hint_panel.modulate.a = 0.0
	_setup_style()


func show_hint(text: String, duration: float = 0.0) -> void:
	if is_instance_valid(hide_tween):
		hide_tween.kill()
	if is_instance_valid(visible_tween):
		visible_tween.kill()

	hint_label.text = text
	icon_label.text = "!"
	visible = true
	hint_panel.visible = true

	visible_tween = create_tween()
	visible_tween.tween_property(hint_panel, "modulate:a", 1.0, 0.18)

	if duration > 0.0:
		hide_tween = create_tween()
		hide_tween.tween_interval(duration)
		hide_tween.tween_callback(Callable(self, "hide_hint"))


func hide_hint() -> void:
	if is_instance_valid(visible_tween):
		visible_tween.kill()

	visible_tween = create_tween()
	visible_tween.tween_property(hint_panel, "modulate:a", 0.0, 0.15)
	visible_tween.chain().tween_callback(Callable(self, "_finish_hide"))


func _finish_hide() -> void:
	hint_panel.visible = false


func _setup_style() -> void:
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.035, 0.04, 0.86)
	panel_style.border_color = Color(0.95, 0.78, 0.38, 0.85)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.shadow_color = Color(0, 0, 0, 0.45)
	panel_style.shadow_size = 14
	hint_panel.add_theme_stylebox_override("panel", panel_style)

	icon_label.add_theme_color_override("font_color", Color(0.95, 0.78, 0.38))
	hint_label.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88))
