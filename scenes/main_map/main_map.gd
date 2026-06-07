extends Node2D
@onready var fade_transition: ColorRect = $fade_transition
@onready var fade_animation: AnimationPlayer = $fade_transition/AnimationPlayer
@onready var music_animation: AnimationPlayer = $background_music/music_animation
@onready var death_screen: CanvasLayer = $DeathScreen
@onready var background_music: AudioStreamPlayer = $background_music

var fps_layer: CanvasLayer
var fps_label: Label
var fps_visible := false
var fps_toggle_pressed := false
var fps_update_time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	var graphics_settings = get_node_or_null("/root/GraphicsSettings")
	if graphics_settings:
		graphics_settings.apply_runtime_settings()
		graphics_settings.apply_to_tree(self)
		graphics_settings.connect("settings_changed", Callable(self, "_on_graphics_settings_changed"))
	background_music.bus = AudioSettings.MUSIC_BUS
	AudioSettings.apply_volumes()
	_create_fps_counter()
	fade_transition.show()
	fade_animation.play("fade_out")


func _process(delta: float) -> void:
	_update_fps_toggle()
	if fps_visible:
		fps_update_time += delta
		if fps_update_time >= 0.2:
			fps_update_time = 0.0
			fps_label.text = "FPS: %d" % Engine.get_frames_per_second()


func reset_scene():
	fade_transition.show()
	fade_animation.speed_scale = 4
	fade_animation.play("fade_in")
	music_animation.play_backwards("music_fade_in")
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()


func show_death_screen():
	death_screen.show_death_screen()


func _on_moving_platform_platform_first_used() -> void:
	music_animation.play("music_fade_in")
	background_music.play()


func _on_graphics_settings_changed() -> void:
	var graphics_settings = get_node_or_null("/root/GraphicsSettings")
	if graphics_settings:
		graphics_settings.apply_to_tree(self)


func _create_fps_counter() -> void:
	fps_layer = CanvasLayer.new()
	fps_layer.name = "FPSCounter"
	fps_layer.layer = 200
	add_child(fps_layer)

	fps_label = Label.new()
	fps_label.visible = false
	fps_label.position = Vector2(18, 16)
	fps_label.text = "FPS: 0"
	fps_label.add_theme_font_size_override("font_size", 22)
	fps_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.45, 1.0))
	fps_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	fps_label.add_theme_constant_override("shadow_offset_x", 2)
	fps_label.add_theme_constant_override("shadow_offset_y", 2)
	fps_layer.add_child(fps_label)


func _update_fps_toggle() -> void:
	var pressed := Input.is_physical_key_pressed(KEY_F3)
	if pressed and not fps_toggle_pressed:
		fps_visible = not fps_visible
		fps_label.visible = fps_visible
		fps_update_time = 1.0
	fps_toggle_pressed = pressed
