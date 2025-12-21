extends PanelContainer

@onready var item_grid: GridContainer = %ItemGrid

@export var inventory_data: InventoryData

var inventory_item_scene: PackedScene = preload("res://content/UI/Inventory/scenes and scripts/inventory_item.tscn")

func _ready() -> void:
	add_to_group("inventory_ui")
	
	for item_data in inventory_data.items:
		_add_item(item_data)

func _add_item(item_data: ItemData) -> void:
	var inventory_item = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	add_child(inventory_item)
	item_grid._attempt_to_add_item_data(inventory_item)

func add_item(data: ItemData):
	var item = inventory_item_scene.instantiate()
	item.data = data
	add_child(item)
	item_grid._attempt_to_add_item_data(item)

func cleanup():
	if item_grid:
		item_grid.clear_grid()

func rebuild() -> void:
	# Remove existing inventory item nodes
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()

	# Reset grid state
	item_grid.clear_grid()

	# Re-add items from data
	for item_data in inventory_data.items:
		_add_item(item_data)
