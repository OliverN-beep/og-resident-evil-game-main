extends Area2D

@export var ammo_resource: AmmoResource
@export var pickup_amount: int = 6

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	var leftover: int = body.inventory_data.add_ammo(ammo_resource, pickup_amount)
	
	if leftover == 0:
		queue_free()
	
	# Rebuild only the UI associated with this inventory
	for ui in get_tree().get_nodes_in_group("inventory_ui"):
		if ui.inventory_data == body.inventory_data:
			ui.rebuild()
