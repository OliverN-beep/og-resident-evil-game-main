extends Resource
class_name InventoryData

@export var items: Array[ItemData] = []

func has_ammo(ammo_type: String) -> bool:
	for item in items:
		if item.ammo_type == ammo_type and item.ammo_amount > 0:
			return true
	return false

func take_ammo(ammo_type: String, amount: int) -> int:
	var remaining := amount
	
	for item in items:
		if item.ammo_type != ammo_type:
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
