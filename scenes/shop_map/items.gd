extends Node2D
@onready var coins: GPUParticles2D = $coins
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


@export var available_items: Array[ItemData] = []

const EXTRA_ITEMS_PATH := "res://scenes/shop_map/items"
const WEAPON_ITEMS := ["Electric Weapon", "Gravity Grenade", "Self Guiding Missile"]
const SHOP_FONT: FontFile = preload("res://scenes/shop_map/VCR_OSD_MONO_1.001.ttf")


var player_in = {
	"item1": false,
	"item2": false,
	"item3": false
}
@onready var item_1: Area2D = $Item1
@onready var item_2: Area2D = $Item2
@onready var item_3: Area2D = $Item3

var item1: ItemData
var item2: ItemData
var item3: ItemData
var item_offers := {}
var shop_available := true
var shop_hint_label: Label
var shop_message_root: Node2D
var shop_message_label: Label
var shop_message_tween: Tween
var item_nodes := {}
var item_descriptions := {
	"+10HP": "Small heal buffer for longer waves.",
	"+25HP": "Big max health boost.",
	"Electric Weapon": "Chains lightning through nearby enemies.",
	"Gravity Grenade": "Pulls groups together for crowd control.",
	"Self Guiding Missile": "Strong homing shot for priority targets.",
	"1,5x Damage": "Huge permanent damage spike.",
	"+20% Damage": "Reliable permanent damage boost.",
	"+8% Move Speed": "Better dodging and kiting.",
	"-10% Weapon Cooldown": "Fire every weapon more often.",
	"+25% Dash Damage": "Turns dash kills into a combo tool."
}
var rarity_colors := {
	"COMMON": Color(0.9, 0.9, 0.84, 1.0),
	"RARE": Color(0.42, 0.78, 1.0, 1.0),
	"EPIC": Color(0.82, 0.45, 1.0, 1.0),
	"CURSED": Color(1.0, 0.28, 0.22, 1.0),
}

func _ready() -> void:
	item_nodes = {
		"item1": item_1,
		"item2": item_2,
		"item3": item_3,
	}
	create_shop_info_labels()
	load_item_resources()
	randomize_items()

func _process(_delta: float) -> void:
	if not shop_available:
		return
	if player_in["item1"] and Input.is_action_just_pressed("interaction"):
		attempt_purchase("item1")
		return
	if player_in["item2"] and Input.is_action_just_pressed("interaction"):
		attempt_purchase("item2")
		return
	if player_in["item3"] and Input.is_action_just_pressed("interaction"):
		attempt_purchase("item3")
		return


func attempt_purchase(item_key: String) -> void:
	var item := item_offers.get(item_key) as ItemData
	if item == null:
		return
	var price: int = DifficultySettings.get_shop_price(item.price)
	if PlayerData.player_coins < price:
		show_shop_message("Need %d more coins" % (price - PlayerData.player_coins), Color(1.0, 0.45, 0.35, 1.0))
		return
	var players: Array[Node] = get_tree().get_nodes_in_group("Player")
	if players.is_empty():
		return
	var player: Node2D = players[0] as Node2D
	if player == null:
		return
	coins.global_position = player.global_position
	coins.amount = price
	coins.emitting = true
	PlayerData.player_coins -= price
	give_item(item)
	audio_stream_player.play()
	show_shop_message("Picked: %s" % item.item_name, Color(0.55, 1.0, 0.65, 1.0))
	remove_purchased_item(item_key)


func randomize_items() -> void:
	var text: String
	var items_list: Array[ItemData] = get_available_shop_items()
	if items_list.size() < 3:
		push_warning("Shop needs at least 3 available items after filtering owned weapons.")
		return
	item1 = items_list.pick_random()
	item_offers["item1"] = item1
	text = get_item_offer_text(item1)
	get_node("Item1/Node2D/Label").text = text
	set_item_texture("Item1", item1)
	apply_item_rarity_style("Item1", item1)
	items_list.erase(item1)
	
	item2 = items_list.pick_random()
	item_offers["item2"] = item2
	text = get_item_offer_text(item2)
	get_node("Item2/Node2D/Label").text = text
	set_item_texture("Item2", item2)
	apply_item_rarity_style("Item2", item2)
	items_list.erase(item2)
	
	item3 = items_list.pick_random()
	item_offers["item3"] = item3
	text = get_item_offer_text(item3)
	get_node("Item3/Node2D/Label").text = text
	set_item_texture("Item3", item3)
	apply_item_rarity_style("Item3", item3)
	items_list.erase(item3)
	

func give_item(item: ItemData) -> void:
	match item.item_name:
		"+10HP":
			PlayerData.max_health += 10
		"+25HP":
			PlayerData.max_health += 25
		"Electric Weapon":
			add_weapon_once("Electric Weapon")
		"Gravity Grenade":
			add_weapon_once("Gravity Grenade")
		"Self Guiding Missile":
			add_weapon_once("Self Guiding Missile")
		"1,5x Damage":
			PlayerData.attack *= 1.5
		"+20% Damage":
			PlayerData.attack *= 1.2
		"+8% Move Speed":
			PlayerData.movement_speed_multiplier *= 1.08
		"-10% Weapon Cooldown":
			PlayerData.cooldown_upgrade_multiplier = max(PlayerData.cooldown_upgrade_multiplier * 0.9, 0.65)
		"+25% Dash Damage":
			PlayerData.dash_damage_multiplier *= 1.25


func add_weapon_once(weapon_name: String) -> void:
	if weapon_name not in PlayerData.owned_weapons:
		PlayerData.owned_weapons.append(weapon_name)


func load_item_resources() -> void:
	var dir := DirAccess.open(EXTRA_ITEMS_PATH)
	if dir == null:
		return

	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var resource: Resource = load(EXTRA_ITEMS_PATH + "/" + file_name)
		var item: ItemData = resource as ItemData
		if item != null and not has_item_named(item.item_name):
			available_items.append(item)


func has_item_named(item_name: String) -> bool:
	for item in available_items:
		if item != null and item.item_name == item_name:
			return true
	return false


func get_available_shop_items() -> Array[ItemData]:
	var filtered_items: Array[ItemData] = []
	for item in available_items:
		if item == null:
			continue
		if is_owned_weapon_item(item):
			continue
		filtered_items.append(item)
	return filtered_items


func is_owned_weapon_item(item: ItemData) -> bool:
	var is_weapon := item.type == "Weapon" or item.item_name in WEAPON_ITEMS
	return is_weapon and item.item_name in PlayerData.owned_weapons


func set_item_texture(item_node_name: String, item: ItemData) -> void:
	if item.texture == null:
		return
	var sprite: Sprite2D = get_node_or_null(item_node_name + "/Sprite2D") as Sprite2D
	if sprite != null:
		sprite.texture = item.texture


func get_item_offer_text(item: ItemData) -> String:
	var description: String = item_descriptions.get(item.item_name, "Permanent upgrade.")
	var rarity := get_item_rarity(item)
	var price := DifficultySettings.get_shop_price(item.price)
	return "[%s]\n%s\n%d coins\n%s\nPress F" % [rarity, item.item_name, price, description]


func remove_purchased_item(item_key: String) -> void:
	player_in[item_key] = false
	item_offers.erase(item_key)

	var item_node: Node2D = item_nodes.get(item_key) as Node2D
	if item_node and is_instance_valid(item_node):
		item_node.queue_free()

	if item_offers.is_empty():
		shop_available = false
	else:
		update_shop_hint()


func update_shop_hint() -> void:
	if not shop_hint_label:
		return
	shop_hint_label.text = ""


func get_item_rarity(item: ItemData) -> String:
	if item.item_name == "1,5x Damage":
		return "CURSED"
	if item.price >= 80:
		return "EPIC"
	if item.type == "Weapon" or item.price >= 50:
		return "RARE"
	return "COMMON"


func get_item_rarity_color(item: ItemData) -> Color:
	return rarity_colors.get(get_item_rarity(item), Color.WHITE)


func apply_item_rarity_style(item_node_name: String, item: ItemData) -> void:
	var color := get_item_rarity_color(item)
	var item_node := get_node_or_null(item_node_name) as Node2D
	if item_node:
		item_node.modulate = Color.WHITE

	var sprite := get_node_or_null(item_node_name + "/Sprite2D") as Sprite2D
	if sprite:
		sprite.modulate = color

	var label := get_node_or_null(item_node_name + "/Node2D/Label") as Label
	if label:
		label.add_theme_color_override("font_color", color)
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))


func create_shop_info_labels() -> void:
	prepare_offer_label("Item1")
	prepare_offer_label("Item2")
	prepare_offer_label("Item3")

	shop_hint_label = Label.new()
	shop_hint_label.name = "ShopHint"
	shop_hint_label.position = Vector2(-250, -184)
	shop_hint_label.custom_minimum_size = Vector2(500, 42)
	shop_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shop_hint_label.text = ""
	shop_hint_label.visible = false
	shop_hint_label.add_theme_font_size_override("font_size", 24)
	shop_hint_label.add_theme_font_override("font", SHOP_FONT)
	shop_hint_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.48, 1.0))
	shop_hint_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	shop_hint_label.add_theme_constant_override("shadow_offset_x", 2)
	shop_hint_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(shop_hint_label)

	shop_message_root = Node2D.new()
	shop_message_root.name = "ShopMessageRoot"
	shop_message_root.position = Vector2(-250, 74)
	shop_message_root.scale = Vector2(0.16, 0.16)
	add_child(shop_message_root)

	shop_message_label = Label.new()
	shop_message_label.name = "ShopMessage"
	shop_message_label.position = Vector2.ZERO
	shop_message_label.custom_minimum_size = Vector2(3125, 225)
	shop_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shop_message_label.modulate.a = 0.0
	shop_message_label.add_theme_font_override("font", SHOP_FONT)
	shop_message_label.add_theme_font_size_override("font_size", 120)
	shop_message_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	shop_message_label.add_theme_constant_override("shadow_offset_x", 10)
	shop_message_label.add_theme_constant_override("shadow_offset_y", 10)
	shop_message_root.add_child(shop_message_label)


func prepare_offer_label(item_node_name: String) -> void:
	var label := get_node_or_null(item_node_name + "/Node2D/Label") as Label
	if not label:
		return

	label.offset_left = -520.0
	label.offset_top = -168.0
	label.offset_right = 520.0
	label.offset_bottom = 88.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if label.label_settings:
		label.label_settings = label.label_settings.duplicate()
		label.label_settings.font_size = 88


func show_shop_message(text: String, color: Color) -> void:
	if not shop_message_label:
		return
	if shop_message_tween:
		shop_message_tween.kill()

	shop_message_label.text = text
	shop_message_label.add_theme_color_override("font_color", color)
	shop_message_label.modulate.a = 1.0

	shop_message_tween = create_tween()
	shop_message_tween.tween_property(shop_message_label, "modulate:a", 0.0, 0.3).set_delay(1.35)


func set_item_highlight(item_key: String, highlighted: bool) -> void:
	var item_node: Node2D = item_nodes.get(item_key) as Node2D
	if not item_node or not is_instance_valid(item_node):
		return

	var target_scale := Vector2(1.12, 1.12) if highlighted else Vector2.ONE
	var target_modulate := Color(1.25, 1.18, 0.82, 1.0) if highlighted else Color.WHITE
	item_node.scale = target_scale
	item_node.modulate = target_modulate


#signals for knowing in which item is player standing
func _on_item_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item1"] = true
		set_item_highlight("item1", true)
func _on_item_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item2"] = true
		set_item_highlight("item2", true)
func _on_item_3_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item3"] = true
		set_item_highlight("item3", true)
func _on_item_1_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item1"] = false
		set_item_highlight("item1", false)
func _on_item_2_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item2"] = false
		set_item_highlight("item2", false)
func _on_item_3_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item3"] = false
		set_item_highlight("item3", false)
