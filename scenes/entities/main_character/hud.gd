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
var wave_banner_tween: Tween
var score_tween: Tween
var score_panel: PanelContainer
var score_value_label: Label
var score_mult_label: Label
var combo_bar_fill: StyleBoxFlat
var effect_layer: Control
var screen_flash: ColorRect
var overdrive_overlay: ColorRect
var milestone_banner: Label
var wave_banner: Label
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
	PlayerData.wave_cleared.connect(_on_wave_cleared)
	PlayerData.score_changed.connect(_on_score_changed)
	PlayerData.score_gained.connect(_on_score_gained)
	_create_score_panel()
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
	var reward_text := _get_milestone_reward_text(combo_count)
	combo_status_label.text = milestone_name if reward_text.is_empty() else "%s  %s" % [milestone_name, reward_text]
	_apply_combo_color(combo_count)
	_play_combo_milestone_effect(combo_count, milestone_name, reward_text)
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


func _on_wave_cleared(wave_number: int) -> void:
	_show_wave_banner("WAVE %d CLEARED" % wave_number, Color(0.54, 0.96, 1.0, 1))


func _show_wave_banner(text: String, color: Color) -> void:
	if not wave_banner:
		return

	wave_banner.text = text
	wave_banner.visible = true
	wave_banner.modulate = Color(1, 1, 1, 1)
	wave_banner.scale = Vector2(1.12, 1.12)
	wave_banner.add_theme_color_override("font_color", color)

	if wave_banner_tween:
		wave_banner_tween.kill()
	wave_banner_tween = create_tween()
	wave_banner_tween.set_parallel(true)
	wave_banner_tween.tween_property(wave_banner, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	wave_banner_tween.tween_property(wave_banner, "modulate:a", 0.0, 0.38).set_delay(1.0)
	wave_banner_tween.tween_callback(func(): wave_banner.visible = false).set_delay(1.42)


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
	if score_value_label:
		score_value_label.text = str(PlayerData.run_score)


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


func _create_score_panel() -> void:
	score_panel = PanelContainer.new()
	score_panel.name = "ScorePanel"
	score_panel.position = Vector2(760, 24)
	score_panel.custom_minimum_size = Vector2(400, 72)
	score_panel.pivot_offset = Vector2(200, 36)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.032, 0.028, 0.024, 0.82)
	panel_style.border_color = Color(1.0, 0.74, 0.26, 0.72)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.content_margin_left = 16
	panel_style.content_margin_top = 8
	panel_style.content_margin_right = 16
	panel_style.content_margin_bottom = 8
	score_panel.add_theme_stylebox_override("panel", panel_style)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	score_panel.add_child(box)

	var title := Label.new()
	title.text = "SCORE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.78, 0.72, 0.62, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 1)
	title.add_theme_constant_override("shadow_offset_y", 1)
	title.add_theme_font_size_override("font_size", 13)
	box.add_child(title)

	score_value_label = Label.new()
	score_value_label.name = "ScoreValue"
	score_value_label.text = "0"
	score_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_value_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.28, 1.0))
	score_value_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	score_value_label.add_theme_constant_override("shadow_offset_x", 3)
	score_value_label.add_theme_constant_override("shadow_offset_y", 3)
	score_value_label.add_theme_font_size_override("font_size", 34)
	box.add_child(score_value_label)

	score_mult_label = Label.new()
	score_mult_label.name = "ScoreMultiplier"
	score_mult_label.text = "x%.2f difficulty" % DifficultySettings.get_score_multiplier()
	score_mult_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_mult_label.add_theme_color_override("font_color", Color(0.52, 0.95, 1.0, 1.0))
	score_mult_label.add_theme_font_size_override("font_size", 12)
	box.add_child(score_mult_label)
	root.add_child(score_panel)


func _on_score_changed(score: int) -> void:
	if not score_value_label:
		return
	score_value_label.text = str(score)
	score_panel.scale = Vector2(1.08, 1.08)
	score_value_label.modulate = Color(1.35, 1.25, 0.72, 1.0)
	if score_tween:
		score_tween.kill()
	score_tween = create_tween()
	score_tween.set_parallel(true)
	score_tween.tween_property(score_panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	score_tween.tween_property(score_value_label, "modulate", Color.WHITE, 0.2)


func _on_score_gained(amount: int, _total_score: int, reason: String, world_position: Vector2, multiplier: float) -> void:
	var text := "+%d" % amount
	if multiplier >= 1.15:
		text = "%s  x%.2f" % [text, multiplier]
	var color := _get_score_reason_color(reason, multiplier)
	if reason == "wave":
		_show_wave_banner("WAVE BONUS  +%d" % amount, color)
		_spawn_score_popup(text, Vector2(960, 162), color, true)
	else:
		_spawn_score_popup(text, _score_world_to_screen(world_position), color, false)


func _spawn_score_popup(text: String, screen_position: Vector2, color: Color, big := false) -> void:
	if not effect_layer:
		return

	var label := Label.new()
	label.name = "ScorePopup"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(240, 54) if big else Vector2(170, 42)
	label.position = screen_position - label.custom_minimum_size * 0.5 + Vector2(randf_range(-14.0, 14.0), randf_range(-10.0, 8.0))
	label.pivot_offset = label.custom_minimum_size * 0.5
	label.add_theme_font_size_override("font_size", 34 if big else 24)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	effect_layer.add_child(label)

	_spawn_score_sparks(screen_position, color, big)

	var popup_tween := create_tween()
	popup_tween.set_parallel(true)
	popup_tween.tween_property(label, "position", label.position + Vector2(0, -54 if big else -38), 0.52).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	popup_tween.tween_property(label, "scale", Vector2(1.22, 1.22) if big else Vector2(1.12, 1.12), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	popup_tween.tween_property(label, "scale", Vector2.ONE, 0.18).set_delay(0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	popup_tween.tween_property(label, "modulate:a", 0.0, 0.22).set_delay(0.36)
	popup_tween.tween_callback(label.queue_free).set_delay(0.62)


func _spawn_score_sparks(screen_position: Vector2, color: Color, big: bool) -> void:
	var spark_count: int = 8 if big else 5
	for i in range(spark_count):
		var spark := ColorRect.new()
		spark.name = "ScoreSpark"
		spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		spark.color = Color(color.r, color.g, color.b, 0.54)
		spark.size = Vector2(randf_range(12.0, 26.0), randf_range(2.0, 3.5))
		spark.pivot_offset = spark.size * 0.5
		spark.rotation = TAU * float(i) / float(spark_count) + randf_range(-0.22, 0.22)
		spark.position = screen_position - spark.pivot_offset
		effect_layer.add_child(spark)

		var direction: Vector2 = Vector2.RIGHT.rotated(spark.rotation)
		var distance: float = randf_range(34.0, 68.0) if big else randf_range(22.0, 44.0)
		var spark_tween := create_tween()
		spark_tween.set_parallel(true)
		spark_tween.tween_property(spark, "position", spark.position + direction * distance, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		spark_tween.tween_property(spark, "scale", Vector2(1.45, 0.35), 0.2)
		spark_tween.tween_property(spark, "modulate:a", 0.0, 0.18).set_delay(0.08)
		spark_tween.tween_callback(spark.queue_free).set_delay(0.3)


func _score_world_to_screen(world_position: Vector2) -> Vector2:
	if world_position == PlayerData.NO_WORLD_SCORE_POSITION:
		return Vector2(960, 180)
	return get_viewport().get_canvas_transform() * world_position


func _get_score_reason_color(reason: String, multiplier: float) -> Color:
	if reason == "wave":
		return Color(0.54, 0.96, 1.0, 1.0)
	if reason == "dash":
		return Color(0.62, 0.9, 1.0, 1.0)
	if reason == "gravity_grenade":
		return Color(0.78, 0.48, 1.0, 1.0)
	if multiplier >= 1.6:
		return Color(1.0, 0.32, 0.22, 1.0)
	if multiplier >= 1.25:
		return Color(1.0, 0.68, 0.2, 1.0)
	return Color(1.0, 0.88, 0.32, 1.0)


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

	wave_banner = Label.new()
	wave_banner.name = "WaveClearedBanner"
	wave_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	wave_banner.custom_minimum_size = Vector2(620, 92)
	wave_banner.position = Vector2(-310, 108)
	wave_banner.pivot_offset = Vector2(310, 46)
	wave_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wave_banner.visible = false
	wave_banner.add_theme_font_size_override("font_size", 34)
	wave_banner.add_theme_color_override("font_color", Color(0.54, 0.96, 1.0, 1))
	wave_banner.add_theme_color_override("font_shadow_color", Color(0.01, 0.02, 0.025, 0.95))
	wave_banner.add_theme_constant_override("shadow_offset_x", 3)
	wave_banner.add_theme_constant_override("shadow_offset_y", 3)
	effect_layer.add_child(wave_banner)


func _play_combo_milestone_effect(combo_count: int, milestone_name: String, reward_text: String = "") -> void:
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

	milestone_banner.text = milestone_name if reward_text.is_empty() else "%s\n%s" % [milestone_name, reward_text]
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


func _get_milestone_reward_text(combo_count: int) -> String:
	if combo_count >= 12:
		return "+5 COINS"
	if combo_count >= 9:
		return "+8 HP"
	if combo_count >= 6:
		return "+2 COINS"
	if combo_count >= 3:
		return "+4 HP"
	return ""
