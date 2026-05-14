extends Node2D
@onready var coins: GPUParticles2D = $coins
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


@export var available_items: Array[ItemData] = []


var player_in = {
	"item1": false,
	"item2": false,
	"item3": false
}
@onready var item_1: Area2D = $Item1
@onready var item_2: Area2D = $Item2
@onready var item_3: Area2D = $Item3

var item1
var item2
var item3

var player_coins = PlayerData.player_coins

func _ready() -> void:
	randomize_items()

func _process(delta: float) -> void:
	if player_in["item1"] and Input.is_action_just_pressed("interaction"):
		attempt_purchase(item1)
	if player_in["item2"] and Input.is_action_just_pressed("interaction"):
		attempt_purchase(item2)
	if player_in["item3"] and Input.is_action_just_pressed("interaction"):
		attempt_purchase(item3)

func delete_items():
		item_2.queue_free()
		item_3.queue_free()
		item_1.queue_free()


func attempt_purchase(item):
	print("attempt")
	var price = item.price
	if PlayerData.player_coins < price:
		print("not enough money")
		return
	coins.global_position = get_tree().get_nodes_in_group("Player")[0].global_position
	coins.amount = price
	coins.emitting = true
	PlayerData.player_coins -= price
	give_item(item)
	audio_stream_player.play()
	delete_items()


func randomize_items():
	var items_list = available_items.duplicate()
	item1 = items_list.pick_random()
	get_node("Item1/Node2D/Label").text = item1.item_name
	items_list.erase(item1)
	
	item2 = items_list.pick_random()
	get_node("Item2/Node2D/Label").text = item2.item_name
	items_list.erase(item2)
	
	item3 = items_list.pick_random()
	get_node("Item3/Node2D/Label").text = item3.item_name
	items_list.erase(item3)
	

func give_item(item):
	if item.item_name == "+10HP":
		PlayerData.max_health+=10
	if item.item_name == "Electric Weapon":
		PlayerData.owned_weapons.append("Electric Weapon")
	if item.item_name == "Gravity Grenade":
		PlayerData.owned_weapons.append("Gravity Grenade")
	if item.item_name == "Self Guiding Missile":
		PlayerData.owned_weapons.append("Self Guiding Missile")
	if item.item_name == "1,5x Damage":
		PlayerData.attack *= 1.5
		print(PlayerData.attack)






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
