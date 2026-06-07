extends Node

signal settings_changed

const CONFIG_PATH := "user://graphics_settings.cfg"
const HIGH := "high"
const MEDIUM := "medium"
const LOW := "low"
const POTATO := "potato"

const PRESET_ORDER := [HIGH, MEDIUM, LOW, POTATO]
const PRESET_LABELS := {
	HIGH: "HIGH",
	MEDIUM: "MEDIUM",
	LOW: "LOW",
	POTATO: "POTATO",
}

const PRESETS := {
	HIGH: {
		"particle_scale": 1.0,
		"glow": true,
		"pause_blur": true,
		"map_shadows": true,
		"player_shadow": true,
		"effect_shadows": true,
		"effect_lights": true,
	},
	MEDIUM: {
		"particle_scale": 0.75,
		"glow": true,
		"pause_blur": true,
		"map_shadows": true,
		"player_shadow": true,
		"effect_shadows": false,
		"effect_lights": true,
	},
	LOW: {
		"particle_scale": 0.55,
		"glow": true,
		"pause_blur": false,
		"map_shadows": false,
		"player_shadow": true,
		"effect_shadows": false,
		"effect_lights": true,
	},
	POTATO: {
		"particle_scale": 0.35,
		"glow": false,
		"pause_blur": false,
		"map_shadows": false,
		"player_shadow": false,
		"effect_shadows": false,
		"effect_lights": false,
	},
}

var preset := HIGH


func _ready() -> void:
	load_settings()
	apply_runtime_settings()


func set_preset(value: String) -> void:
	if not PRESETS.has(value):
		value = HIGH
	preset = value
	_save_settings()
	apply_runtime_settings()
	settings_changed.emit()


func get_preset_label(value := preset) -> String:
	return PRESET_LABELS.get(value, "HIGH")


func get_preset_order() -> Array:
	return PRESET_ORDER.duplicate()


func get_preset_description(value := preset) -> String:
	match value:
		HIGH:
			return "Native resolution, full glow, full shadows."
		MEDIUM:
			return "Full resolution, cheaper effect shadows."
		LOW:
			return "Player shadow and glow kept, cheaper map shadows."
		POTATO:
			return "Lowest GPU cost, no shadows, reduced effects."
	return ""


func get_value(key: String, fallback: Variant = null) -> Variant:
	return PRESETS.get(preset, PRESETS[HIGH]).get(key, fallback)


func apply_runtime_settings() -> void:
	var root := get_tree().root
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_factor = 1.0
	Engine.max_fps = 0


func apply_to_tree(root: Node) -> void:
	if root == null:
		return
	apply_to_node(root)
	for child in root.get_children():
		apply_to_tree(child)


func apply_to_node(node: Node) -> void:
	if node == null:
		return
	if node is Light2D:
		_apply_to_light(node as Light2D)
	elif node is GPUParticles2D:
		_apply_to_particles(node as GPUParticles2D)
	elif node is WorldEnvironment:
		_apply_to_world_environment(node as WorldEnvironment)


func should_use_pause_blur() -> bool:
	return bool(get_value("pause_blur", true))


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	preset = str(config.get_value("graphics", "preset", HIGH))
	if not PRESETS.has(preset):
		preset = HIGH


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("graphics", "preset", preset)
	config.save(CONFIG_PATH)


func _apply_to_light(light: Light2D) -> void:
	if not light.has_meta("graphics_base_enabled"):
		light.set_meta("graphics_base_enabled", light.enabled)
		light.set_meta("graphics_base_shadow_enabled", light.shadow_enabled)

	var category := _get_light_category(light)
	var base_enabled: bool = bool(light.get_meta("graphics_base_enabled"))
	var base_shadow: bool = bool(light.get_meta("graphics_base_shadow_enabled"))
	light.enabled = base_enabled
	light.shadow_enabled = base_shadow

	var screen_notifier := light.get_node_or_null("VisibleOnScreenNotifier2D") as VisibleOnScreenNotifier2D
	if screen_notifier != null and not screen_notifier.is_on_screen():
		light.enabled = false

	match category:
		"player":
			light.shadow_enabled = base_shadow and bool(get_value("player_shadow", true))
		"map":
			light.shadow_enabled = base_shadow and bool(get_value("map_shadows", true))
		"effect":
			light.enabled = base_enabled and bool(get_value("effect_lights", true))
			light.shadow_enabled = base_shadow and bool(get_value("effect_shadows", true))


func _apply_to_particles(particles: GPUParticles2D) -> void:
	if not particles.has_meta("graphics_base_amount"):
		particles.set_meta("graphics_base_amount", particles.amount)
		particles.set_meta("graphics_base_trail_sections", particles.trail_sections)

	var particle_scale: float = float(get_value("particle_scale", 1.0))
	var base_amount: int = int(particles.get_meta("graphics_base_amount"))
	var base_trail_sections: int = int(particles.get_meta("graphics_base_trail_sections"))
	particles.amount = max(1, int(round(float(base_amount) * particle_scale)))
	if base_trail_sections > 0:
		particles.trail_sections = max(2, int(round(float(base_trail_sections) * particle_scale)))
	particles.fixed_fps = 30


func _apply_to_world_environment(world_environment: WorldEnvironment) -> void:
	if world_environment.environment == null:
		return
	if not world_environment.has_meta("graphics_base_glow_enabled"):
		world_environment.set_meta("graphics_base_glow_enabled", world_environment.environment.glow_enabled)
	world_environment.environment.glow_enabled = bool(world_environment.get_meta("graphics_base_glow_enabled")) and bool(get_value("glow", true))


func _get_light_category(light: Light2D) -> String:
	var path := str(light.get_path()).to_lower()
	var parent := light.get_parent()
	if parent != null and parent.is_in_group("Player"):
		return "player"
	if path.contains("characterbody2d/pointlight2d"):
		return "player"
	if path.contains("torch_light") or path.contains("light_sources") or light is DirectionalLight2D:
		return "map"
	return "effect"
