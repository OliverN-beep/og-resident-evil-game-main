extends CanvasLayer

@onready var item_grid: GridContainer = %ItemGrid

@export var inventory_data: InventoryData

var inventory_item_scene: PackedScene = preload("res://content/UI/Inventory/scenes and scripts/inventory_item.tscn")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	for item_data in inventory_data.items:
		_add_item(item_data)

func _add_item(item_data: ItemData) -> void:
	var inventory_item = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	
	item_grid.add_child(inventory_item)
	
	# Restore rotation FIRST
	inventory_item.data.is_rotated = item_data.is_rotated
	inventory_item.update_visual_rotation()
	
	var index = item_data.grid_index
	
	if index != -1:
		var dims = inventory_item.get_dimensions()
		
		if item_grid._item_fits(index, dims):
			inventory_item.get_placed(item_grid._get_coords_from_slot_index(index))
			item_grid.add_item_to_slot_data(index, inventory_item)
		else:
			# check position (debug)
			print("Invalid position, fallback:", item_data.name)
			item_grid._attempt_to_add_item_data(inventory_item)
	else:
		# Only new items should go here
		item_grid._attempt_to_add_item_data(inventory_item)
	
	print("LOAD:", item_data.name, "index:", index)

func cleanup():
	if item_grid:
		# Save
		_save_layout_to_data()
		# Clear
		item_grid.clear_grid()

func rebuild() -> void:
	# Reset grid state
	item_grid.clear_grid()
	
	# Re-add items from data
	for item_data in inventory_data.items:
		_add_item(item_data)

func _save_layout_to_data():
	var seen := {}
	inventory_data.items.clear()
	
	for i in range(item_grid.slot_data.size()):
		var item = item_grid.slot_data[i]
		if item == null:
			continue
		
		if seen.has(item):
			continue
		
		seen[item] = true
		
		var data: ItemData = item.data
		
		var anchor = item.get_anchor_point()
		var index = item_grid._get_slot_index_from_coords(anchor)
		
		if index == -1:
			continue
		
		data.grid_index = index
		data.is_rotated = item.data.is_rotated
		
		var new_data: ItemData = data.duplicate(true)

		new_data.grid_index = index
		new_data.is_rotated = item.data.is_rotated

		inventory_data.items.append(new_data)
		
		print("SAVE:", data.name, "index:", index)
