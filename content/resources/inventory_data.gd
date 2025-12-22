extends Resource
class_name InventoryData

@export var items: Array[ItemData] = []

func has_ammo(ammo_type: String) -> bool:
	for item in items:
		if item.ammo_resource == null:
			continue
		if item.ammo_resource.ammo_type == ammo_type and item.ammo_amount > 0:
			return true
	return false


func take_ammo(ammo_type: String, amount: int) -> int:
	var remaining: int = amount

	for item in items:
		if item.ammo_resource == null:
			continue
		if item.ammo_resource.ammo_type != ammo_type:
			continue
		if item.ammo_amount <= 0:
			continue

		var taken: int = min(item.ammo_amount, remaining)
		item.ammo_amount -= taken
		remaining -= taken

		if item.ammo_amount <= 0:
			items.erase(item)

		if remaining <= 0:
			break

	return amount - remaining

func add_ammo(ammo_res: AmmoResource, amount: int) -> Array[ItemData]:
	var remaining: int = amount
	var new_items: Array[ItemData] = []

	# Fill existing stacks
	for item: ItemData in items:
		if item.ammo_resource != ammo_res:
			continue

		var space: int = ammo_res.max_stack - item.ammo_amount
		if space <= 0:
			continue

		var added: int = min(space, remaining)
		item.ammo_amount += added
		remaining -= added

		if remaining <= 0:
			return new_items

	# Create new stacks
	while remaining > 0:
		var new_item: ItemData = ItemData.new()
		new_item.name = ammo_res.ammo_type
		new_item.texture = ammo_res.icon
		new_item.ammo_resource = ammo_res
		new_item.dimensions = Vector2i(1, 1)

		var added: int = min(ammo_res.max_stack, remaining)
		new_item.ammo_amount = added
		remaining -= added

		items.append(new_item)
		new_items.append(new_item)
	
	return new_items

func get_ammo_stack_count(ammo_type: String) -> int:
	var count := 0
	for item in items:
		if item.ammo_resource == null:
			continue
		if item.ammo_resource.ammo_type == ammo_type:
			count += 1
	return count
