extends Node2D
@onready var coins: GPUParticles2D = $coins
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


@export var available_items: Array[ItemData] = []

const EXTRA_ITEMS_PATH := "res://scenes/shop_map/items"
const WEAPON_ITEMS := ["Electric Weapon", "Gravity Grenade", "Self Guiding Missile"]


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

func _ready() -> void:
	load_item_resources()
	randomize_items()

func _process(_delta: float) -> void:
	if player_in["item1"] and Input.is_action_just_pressed("interaction"):
		attempt_purchase(item1)
	if player_in["item2"] and Input.is_action_just_pressed("interaction"):
		attempt_purchase(item2)
	if player_in["item3"] and Input.is_action_just_pressed("interaction"):
		attempt_purchase(item3)

func delete_items() -> void:
		item_2.queue_free()
		item_3.queue_free()
		item_1.queue_free()


func attempt_purchase(item: ItemData) -> void:
	if item == null:
		return
	var price: int = item.price
	if PlayerData.player_coins < price:
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
	delete_items()


func randomize_items() -> void:
	var text: String
	var items_list: Array[ItemData] = get_available_shop_items()
	if items_list.size() < 3:
		push_warning("Shop needs at least 3 available items after filtering owned weapons.")
		return
	item1 = items_list.pick_random()
	text = item1.item_name + "\n" + str(item1.price)
	get_node("Item1/Node2D/Label").text = text
	#set_item_texture("Item1", item1)
	items_list.erase(item1)
	
	item2 = items_list.pick_random()
	text = item2.item_name + "\n" + str(item2.price)
	get_node("Item2/Node2D/Label").text = text
	#set_item_texture("Item2", item2)
	items_list.erase(item2)
	
	item3 = items_list.pick_random()
	text = item3.item_name + "\n" + str(item3.price)
	get_node("Item3/Node2D/Label").text = text
	#set_item_texture("Item3", item3)
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


#signals for knowing in which item is player standing
func _on_item_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item1"] = true
func _on_item_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item2"] = true
func _on_item_3_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item3"] = true
func _on_item_1_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item1"] = false
func _on_item_2_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item2"] = false
func _on_item_3_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in["item3"] = false
