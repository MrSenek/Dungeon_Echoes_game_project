extends CanvasLayer

@onready var root: Control = $Root
@onready var dim: ColorRect = $Root/Dim
@onready var panel: PanelContainer = $Root/Panel
@onready var restart_button: Button = $Root/Panel/MarginContainer/VBoxContainer/ButtonRow/RestartButton
@onready var quit_button: Button = $Root/Panel/MarginContainer/VBoxContainer/ButtonRow/QuitButton

var show_tween: Tween

func _ready() -> void:
	hide()
	root.modulate.a = 0.0


func show_death_screen() -> void:
	if is_instance_valid(show_tween):
		show_tween.kill()

	show()
	Engine.time_scale = 0
	restart_button.disabled = true
	quit_button.disabled = true

	root.modulate.a = 1.0
	dim.modulate.a = 0.0
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.9, 0.9)
	panel.pivot_offset = panel.size * 0.5

	show_tween = create_tween()
	show_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	show_tween.set_ignore_time_scale(true)
	show_tween.set_parallel(true)
	show_tween.tween_property(dim, "modulate:a", 1.0, 0.28)
	show_tween.tween_property(panel, "modulate:a", 1.0, 0.24).set_delay(0.08)
	show_tween.tween_property(panel, "scale", Vector2.ONE, 0.28).set_delay(0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	show_tween.set_parallel(false)
	show_tween.tween_callback(Callable(self, "_finish_show"))


func _finish_show() -> void:
	restart_button.disabled = false
	quit_button.disabled = false
	restart_button.grab_focus()


func _on_restart_button_pressed() -> void:
	Engine.time_scale = 1
	hide()
	get_tree().current_scene.reset_scene()


func _on_quit_button_pressed() -> void:
	Engine.time_scale = 1
	get_tree().quit()
