extends Area2D

@export var ammo_resource: AmmoResource
@export var pickup_amount: int = 6

var can_interact: bool = false
var player_ref: Player

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		var new_items: Array[ItemData] = player_ref.inventory_data.add_ammo(ammo_resource, pickup_amount)
		
		for ui in get_tree().get_nodes_in_group("inventory_ui"):
			if ui.inventory_data == player_ref.inventory_data:
				for item_data: ItemData in new_items:
					ui.add_item(item_data)
		
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		can_interact = true
		player_ref = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = false
		player_ref = null
