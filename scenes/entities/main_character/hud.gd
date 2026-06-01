extends CanvasLayer

@onready var round_value: Label = $Root/TopRightStats/RoundPanel/RoundBox/RoundValue
@onready var coins_value: Label = $Root/TopRightStats/CoinPanel/CoinBox/CoinsValue
@onready var max_round_value: Label = $Root/TopRightStats/MaxRoundPanel/MaxRoundBox/MaxRoundValue
@onready var root: Control = $Root

@onready var weapon_slots := {
	"fireball": {
		"slot": $Root/BottomWeaponBar/FireballSlot,
		"cooldown": $Root/BottomWeaponBar/FireballSlot/SlotBox/CooldownBar,
		"key": $Root/BottomWeaponBar/FireballSlot/SlotBox/Header/Key,
	},
	"electro": {
		"slot": $Root/BottomWeaponBar/ElectroSlot,
		"cooldown": $Root/BottomWeaponBar/ElectroSlot/SlotBox/CooldownBar,
		"key": $Root/BottomWeaponBar/ElectroSlot/SlotBox/Header/Key,
	},
	"missile": {
		"slot": $Root/BottomWeaponBar/MissileSlot,
		"cooldown": $Root/BottomWeaponBar/MissileSlot/SlotBox/CooldownBar,
		"key": $Root/BottomWeaponBar/MissileSlot/SlotBox/Header/Key,
	},
	"gravity_grenade": {
		"slot": $Root/BottomWeaponBar/GrenadeSlot,
		"cooldown": $Root/BottomWeaponBar/GrenadeSlot/SlotBox/CooldownBar,
		"key": $Root/BottomWeaponBar/GrenadeSlot/SlotBox/Header/Key,
	},
}


var cooldowns: Dictionary = {}
var combo_panel: PanelContainer
var combo_label: Label
var combo_status_label: Label
var combo_timer_bar: ProgressBar
var combo_tween: Tween
var milestone_tween: Tween
var screen_fx_tween: Tween
var banner_tween: Tween
var combo_bar_fill: StyleBoxFlat
var effect_layer: Control
var screen_flash: ColorRect
var overdrive_overlay: ColorRect
var milestone_banner: Label
var selected_weapon_id := "fireball"
var slot_styles: Dictionary = {}
var selected_slot_styles: Dictionary = {}
var weapon_aliases := {
	"fireball": "fireball",
	"electro": "electro",
	"electric weapon": "electro",
	"missile": "missile",
	"self guiding missile": "missile",
	"gravity_grenade": "gravity_grenade",
	"gravity grenade": "gravity_grenade",
}


func _ready() -> void:
	Money.coin_collected.connect(_on_coin_collected)
	PlayerData.combo_changed.connect(_on_combo_changed)
	PlayerData.combo_milestone_reached.connect(_on_combo_milestone_reached)
	PlayerData.overdrive_changed.connect(_on_overdrive_changed)
	_create_combo_label()
	_create_combo_effects()
	_prepare_slot_styles()
	_update_stats()
	_update_weapon_slots()


func _process(delta: float) -> void:
	_update_stats()
	_update_weapon_slots()
	_update_cooldowns(delta)
	_update_combo_timer()


func _on_coin_collected(new_amount):
	coins_value.text = str(int(new_amount))


func _on_combo_changed(combo_count: int, damage_multiplier: float, speed_multiplier: float) -> void:
	if not combo_panel:
		return
	if combo_count <= 0:
		combo_panel.visible = false
		return

	combo_label.text = "COMBO x%s" % combo_count
	combo_status_label.text = "DMG %.0f%%  SPD %.0f%%" % [damage_multiplier * 100.0, speed_multiplier * 100.0]
	combo_panel.visible = true
	_apply_combo_color(combo_count)
	combo_panel.scale = Vector2(1.12, 1.12)
	if combo_tween:
		combo_tween.kill()
	combo_tween = create_tween()
	combo_tween.tween_property(combo_panel, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_combo_milestone_reached(combo_count: int, milestone_name: String) -> void:
	if not combo_panel:
		return
	combo_panel.visible = true
	combo_status_label.text = milestone_name
	_apply_combo_color(combo_count)
	_play_combo_milestone_effect(combo_count, milestone_name)
	if milestone_tween:
		milestone_tween.kill()
	milestone_tween = create_tween()
	milestone_tween.set_parallel(true)
	milestone_tween.tween_property(combo_label, "scale", Vector2(1.28, 1.28), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	milestone_tween.tween_property(combo_label, "scale", Vector2.ONE, 0.18).set_delay(0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	milestone_tween.tween_property(combo_panel, "modulate", Color(1.5, 1.5, 1.5, 1), 0.06)
	milestone_tween.tween_property(combo_panel, "modulate", Color.WHITE, 0.22).set_delay(0.06)


func _on_overdrive_changed(active: bool) -> void:
	if not combo_panel:
		return
	if active:
		combo_status_label.text = "OVERDRIVE"
		_apply_combo_color(PlayerData.MAX_COMBO)
	_set_overdrive_overlay(active)


func show_cooldown(weapon_name: String, duration: float) -> void:
	var weapon_id: String = _normalize_weapon_name(weapon_name)
	if not weapon_slots.has(weapon_id):
		return

	cooldowns[weapon_id] = {
		"time_left": duration,
		"duration": duration,
	}

	var bar: ProgressBar = weapon_slots[weapon_id]["cooldown"]
	bar.max_value = duration
	bar.value = duration
	bar.visible = true


func set_selected_weapon(weapon_name: String) -> void:
	var weapon_id: String = _normalize_weapon_name(weapon_name)
	if weapon_slots.has(weapon_id):
		selected_weapon_id = weapon_id
		_update_weapon_slots()


func _update_stats() -> void:
	round_value.text = str(PlayerData.current_round)
	coins_value.text = str(int(PlayerData.player_coins))
	max_round_value.text = str(int(PlayerData.max_round))


func _update_weapon_slots() -> void:
	var owned: Array = PlayerData.owned_weapons.map(func(weapon): return str(weapon).to_lower())

	for weapon_id in weapon_slots:
		var data: Dictionary = weapon_slots[weapon_id]
		var slot: PanelContainer = data["slot"]
		var key: Label = data["key"]

		var unlocked: bool = weapon_id == "fireball" or weapon_id in owned or _is_alias_owned(weapon_id, owned)
		var selected: bool = unlocked and weapon_id == selected_weapon_id
		if selected and selected_slot_styles.has(weapon_id):
			slot.add_theme_stylebox_override("panel", selected_slot_styles[weapon_id])
		elif slot_styles.has(weapon_id):
			slot.add_theme_stylebox_override("panel", slot_styles[weapon_id])
		slot.modulate = Color(1, 1, 1, 1) if unlocked else Color(0.45, 0.45, 0.45, 0.55)
		key.modulate = Color(0.45, 0.95, 1, 1) if selected else Color(1, 0.9, 0.55, 1) if unlocked else Color(0.65, 0.65, 0.65, 1)


func _update_cooldowns(delta: float) -> void:
	for weapon_id in cooldowns.keys():
		var cooldown: Dictionary = cooldowns[weapon_id]
		cooldown["time_left"] = max(cooldown["time_left"] - delta, 0.0)
		cooldowns[weapon_id] = cooldown

		var bar: ProgressBar = weapon_slots[weapon_id]["cooldown"]
		bar.value = cooldown["time_left"]

		if cooldown["time_left"] <= 0.0:
			bar.visible = false
			cooldowns.erase(weapon_id)


func _update_combo_timer() -> void:
	if not combo_timer_bar or PlayerData.combo_count <= 0:
		return
	combo_timer_bar.max_value = PlayerData.COMBO_WINDOW
	combo_timer_bar.value = PlayerData.combo_time_left
	if PlayerData.combo_time_left <= 0.75 and not PlayerData.overdrive_active:
		combo_timer_bar.modulate = Color(1.35, 0.65, 0.55, 1)
	else:
		combo_timer_bar.modulate = Color.WHITE


func _normalize_weapon_name(weapon_name: String) -> String:
	var key: String = weapon_name.to_lower()
	return weapon_aliases.get(key, key)


func _is_alias_owned(weapon_id: String, owned: Array) -> bool:
	for alias in weapon_aliases:
		if weapon_aliases[alias] == weapon_id and alias in owned:
			return true
	return false


func _prepare_slot_styles() -> void:
	for weapon_id in weapon_slots:
		var slot: PanelContainer = weapon_slots[weapon_id]["slot"]
		var base_style := slot.get_theme_stylebox("panel")
		if not base_style:
			continue

		slot_styles[weapon_id] = base_style.duplicate()
		var selected_style = base_style.duplicate()
		var selected_flat := selected_style as StyleBoxFlat
		if selected_flat:
			selected_flat.border_width_left = 2
			selected_flat.border_width_top = 2
			selected_flat.border_width_right = 2
			selected_flat.border_width_bottom = 2
			selected_flat.border_color = Color(0.35, 0.95, 1.0, 0.95)
			selected_flat.bg_color = Color(0.04, 0.09, 0.095, 0.9)
		selected_slot_styles[weapon_id] = selected_style


func _create_combo_label() -> void:
	combo_panel = PanelContainer.new()
	combo_panel.name = "ComboPanel"
	combo_panel.visible = false
	combo_panel.position = Vector2(24, 24)
	combo_panel.custom_minimum_size = Vector2(220, 74)
	combo_panel.pivot_offset = Vector2(110, 37)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.032, 0.028, 0.78)
	panel_style.border_color = Color(0.45, 0.95, 1.0, 0.78)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.content_margin_left = 12
	panel_style.content_margin_top = 8
	panel_style.content_margin_right = 12
	panel_style.content_margin_bottom = 8
	combo_panel.add_theme_stylebox_override("panel", panel_style)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	combo_panel.add_child(box)

	combo_label = Label.new()
	combo_label.name = "ComboLabel"
	combo_label.text = "COMBO x1"
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.add_theme_color_override("font_color", Color(0.45, 0.95, 1.0, 1.0))
	combo_label.add_theme_color_override("font_shadow_color", Color(0.02, 0.02, 0.02, 0.9))
	combo_label.add_theme_constant_override("shadow_offset_x", 2)
	combo_label.add_theme_constant_override("shadow_offset_y", 2)
	combo_label.add_theme_font_size_override("font_size", 28)
	box.add_child(combo_label)

	combo_status_label = Label.new()
	combo_status_label.name = "ComboStatus"
	combo_status_label.text = "DMG 100%  SPD 100%"
	combo_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_status_label.add_theme_color_override("font_color", Color(1.0, 0.93, 0.75, 1.0))
	combo_status_label.add_theme_font_size_override("font_size", 12)
	box.add_child(combo_status_label)

	combo_timer_bar = ProgressBar.new()
	combo_timer_bar.name = "ComboTimer"
	combo_timer_bar.custom_minimum_size = Vector2(0, 7)
	combo_timer_bar.show_percentage = false
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.1, 0.1, 0.1, 0.82)
	bar_bg.corner_radius_top_left = 3
	bar_bg.corner_radius_top_right = 3
	bar_bg.corner_radius_bottom_right = 3
	bar_bg.corner_radius_bottom_left = 3
	combo_bar_fill = StyleBoxFlat.new()
	combo_bar_fill.bg_color = Color(0.45, 0.95, 1.0, 1.0)
	combo_bar_fill.corner_radius_top_left = 3
	combo_bar_fill.corner_radius_top_right = 3
	combo_bar_fill.corner_radius_bottom_right = 3
	combo_bar_fill.corner_radius_bottom_left = 3
	combo_timer_bar.add_theme_stylebox_override("background", bar_bg)
	combo_timer_bar.add_theme_stylebox_override("fill", combo_bar_fill)
	box.add_child(combo_timer_bar)
	root.add_child(combo_panel)


func _create_combo_effects() -> void:
	effect_layer = Control.new()
	effect_layer.name = "ComboEffectLayer"
	effect_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	effect_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(effect_layer)

	overdrive_overlay = ColorRect.new()
	overdrive_overlay.name = "OverdriveOverlay"
	overdrive_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overdrive_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overdrive_overlay.color = Color(0.72, 0.22, 1.0, 0.0)
	effect_layer.add_child(overdrive_overlay)

	screen_flash = ColorRect.new()
	screen_flash.name = "ComboScreenFlash"
	screen_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_flash.color = Color(1, 1, 1, 0)
	effect_layer.add_child(screen_flash)

	milestone_banner = Label.new()
	milestone_banner.name = "ComboMilestoneBanner"
	milestone_banner.set_anchors_preset(Control.PRESET_CENTER)
	milestone_banner.custom_minimum_size = Vector2(640, 92)
	milestone_banner.position = Vector2(-320, -46)
	milestone_banner.pivot_offset = Vector2(320, 46)
	milestone_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	milestone_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	milestone_banner.visible = false
	milestone_banner.add_theme_font_size_override("font_size", 56)
	milestone_banner.add_theme_color_override("font_color", Color(1, 0.86, 0.25, 1))
	milestone_banner.add_theme_color_override("font_shadow_color", Color(0.02, 0.0, 0.0, 0.95))
	milestone_banner.add_theme_constant_override("shadow_offset_x", 4)
	milestone_banner.add_theme_constant_override("shadow_offset_y", 4)
	effect_layer.add_child(milestone_banner)


func _play_combo_milestone_effect(combo_count: int, milestone_name: String) -> void:
	if not screen_flash or not milestone_banner:
		return

	var color := _get_combo_color(combo_count)
	var flash_alpha := 0.16
	var banner_scale := Vector2(1.3, 1.3)
	if combo_count >= PlayerData.MAX_COMBO:
		flash_alpha = 0.12
		banner_scale = Vector2(1.28, 1.28)

	screen_flash.color = Color(color.r, color.g, color.b, flash_alpha)
	if screen_fx_tween:
		screen_fx_tween.kill()
	screen_fx_tween = create_tween()
	screen_fx_tween.tween_property(screen_flash, "color:a", 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	milestone_banner.text = milestone_name
	milestone_banner.visible = true
	milestone_banner.modulate = Color(1, 1, 1, 1)
	milestone_banner.scale = banner_scale
	milestone_banner.add_theme_color_override("font_color", color)
	if banner_tween:
		banner_tween.kill()
	banner_tween = create_tween()
	banner_tween.set_parallel(true)
	banner_tween.tween_property(milestone_banner, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	banner_tween.tween_property(milestone_banner, "modulate:a", 0.0, 0.26).set_delay(0.52).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	banner_tween.tween_callback(func(): milestone_banner.visible = false).set_delay(0.82)

	_spawn_combo_streaks(color, combo_count)


func _spawn_combo_streaks(color: Color, combo_count: int) -> void:
	if not effect_layer:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	var streak_count := 8
	if combo_count >= 9:
		streak_count = 12
	if combo_count >= PlayerData.MAX_COMBO:
		streak_count = 8

	for i in range(streak_count):
		var streak := ColorRect.new()
		streak.name = "ComboStreak"
		streak.mouse_filter = Control.MOUSE_FILTER_IGNORE
		streak.color = Color(color.r, color.g, color.b, 0.42)
		streak.size = Vector2(randf_range(32.0, 86.0), randf_range(2.0, 5.0))
		streak.pivot_offset = streak.size * 0.5
		streak.rotation = randf_range(-0.45, 0.45)
		streak.position = Vector2(
			viewport_size.x * 0.5 + randf_range(-220.0, 220.0),
			viewport_size.y * 0.5 + randf_range(-90.0, 90.0)
		)
		effect_layer.add_child(streak)

		var dir := Vector2.RIGHT.rotated(streak.rotation)
		if i % 2 == 0:
			dir *= -1.0
		var streak_tween := create_tween()
		streak_tween.set_parallel(true)
		streak_tween.tween_property(streak, "position", streak.position + dir * randf_range(170.0, 320.0), 0.36).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		streak_tween.tween_property(streak, "modulate:a", 0.0, 0.28).set_delay(0.08)
		streak_tween.tween_property(streak, "scale", Vector2(1.8, 0.45), 0.32)
		streak_tween.tween_callback(streak.queue_free).set_delay(0.38)


func _set_overdrive_overlay(active: bool) -> void:
	if not overdrive_overlay:
		return
	var target_alpha := 0.0
	if active:
		target_alpha = 0.025
	var tween := create_tween()
	tween.tween_property(overdrive_overlay, "color:a", target_alpha, 0.22)


func _apply_combo_color(combo_count: int) -> void:
	var color := _get_combo_color(combo_count)

	combo_label.add_theme_color_override("font_color", color)
	if combo_bar_fill:
		combo_bar_fill.bg_color = color


func _get_combo_color(combo_count: int) -> Color:
	if combo_count >= 12:
		return Color(0.7, 0.45, 1.0, 1.0)
	if combo_count >= 9:
		return Color(1.0, 0.22, 0.22, 1.0)
	if combo_count >= 6:
		return Color(1.0, 0.48, 0.15, 1.0)
	if combo_count >= 3:
		return Color(1.0, 0.86, 0.25, 1.0)
	return Color(0.45, 0.95, 1.0, 1.0)
