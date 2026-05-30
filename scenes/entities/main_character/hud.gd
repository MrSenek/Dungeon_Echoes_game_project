extends CanvasLayer

@onready var round_value: Label = $Root/TopRightStats/RoundPanel/RoundBox/RoundValue
@onready var coins_value: Label = $Root/TopRightStats/CoinPanel/CoinBox/CoinsValue
@onready var max_round_value: Label = $Root/TopRightStats/MaxRoundPanel/MaxRoundBox/MaxRoundValue

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
	_prepare_slot_styles()
	_update_stats()
	_update_weapon_slots()


func _process(delta: float) -> void:
	_update_stats()
	_update_weapon_slots()
	_update_cooldowns(delta)


func _on_coin_collected(new_amount):
	coins_value.text = str(int(new_amount))


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
