extends GridContainer

const SLOT_SIZE: int = 16

@export var inventory_slot_scene: PackedScene
@export var grid_dimensions: Vector2i

# Represents each slot in our inventory
var slot_data: Array[Node] = []
# handles if item is outside inventory grid
var held_item_intersects: bool = false

func _ready() -> void:
	_create_slots()
	_init_slot_data()
	
	mouse_filter = MOUSE_FILTER_PASS
	
	add_to_group("player_inventory_grid")

func _create_slots() -> void:
	self.columns = grid_dimensions.x
	for y in grid_dimensions.y:
		for x in grid_dimensions.x:
			var inventory_slot = inventory_slot_scene.instantiate()
			add_child(inventory_slot)

func _init_slot_data() -> void:
	slot_data.resize(grid_dimensions.x * grid_dimensions.y)
	slot_data.fill(null)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
		
			var held_item := get_tree().get_first_node_in_group("held_item")
			if held_item and not _is_mouse_over_grid():
				return
			
			if !held_item:
				var _index = _get_slot_index_from_coords(get_global_mouse_position())
				var slot_index = _get_slot_index_from_coords(get_global_mouse_position())
				var item = slot_data[slot_index]
				if !item:
					return
				item.get_picked_up()
				remove_item_from_slot_data(item)
			else:
				if !held_item_intersects: return
				# Ignore if mouse is over another grid
				if not _is_mouse_over_grid():
					return
				
				# offset variable for more intuitive controls
				var offset = Vector2(SLOT_SIZE, SLOT_SIZE) / 2
				var index = _get_slot_index_from_coords(held_item.get_anchor_point() + offset)
				if index == -1:
					return
				var items = items_in_area(index, held_item.get_dimensions())
				if items.size():
					if items.size() == 1:
						held_item.get_placed(_get_coords_from_slot_index(index))
						remove_item_from_slot_data(items[0])
						add_item_to_slot_data(index, held_item)
						items[0].get_picked_up()
					return
				# Save global position before placing
				var saved_global = held_item.global_position
				
				# Reparent into this inventory
				held_item.reparent_to_inventory(self)
				
				# Restore its global position
				held_item.global_position = saved_global
				
				# Place it in grid-local coords
				held_item.get_placed(_get_coords_from_slot_index(index))
				
				# Register in local slot data
				add_item_to_slot_data(index, held_item)
	
	if event is InputEventMouseMotion:
		var held_item = get_tree().get_first_node_in_group("held_item")
		if held_item:
			detect_held_item_intersection(held_item)

func detect_held_item_intersection(held_item: Node) -> void:
	var h_rect = Rect2(held_item.get_anchor_point(), held_item.size)
	var g_rect = Rect2(global_position, size)
	var inter = h_rect.intersection(g_rect).size
	held_item_intersects = (inter.x * inter.y) / (held_item.size.x * held_item.size.y) > 0.8

func remove_item_from_slot_data(item: Node) -> void:
	for i in slot_data.size():
		if slot_data[i] == item:
			slot_data[i] = null

func add_item_to_slot_data(index: int, item: Node) -> void:
	# Reparent only if necessary
	if item.get_parent() != self:
		var prev_global = item.global_position
		if item.get_parent():
			item.get_parent().remove_child(item)
		self.add_child(item)
		item.global_position = prev_global
	
	# Fill slot_data
	for y in item.get_dimensions().y:
		for x in item.get_dimensions().x:
			slot_data[index + x + y * columns] = item

func items_in_area(index: int, item_dimensions: Vector2i) -> Array:
	var items: Dictionary = {}
	for y in item_dimensions.y:
		for x in item_dimensions.x:
			var slot_index = index + x + y * columns
			var item = slot_data[slot_index]
			if !item:
				continue
			if !items.has(item):
				items[item] = true
	return items.keys() if items.size() else []

func _attempt_to_add_item_data(item: Node) -> bool:
	var slot_index: int = 0
	var dims = item.get_dimensions()
	
	# Try default orientation
	while slot_index < slot_data.size():
		if _item_fits(slot_index, dims):
			for y in dims.y:
				for x in dims.x:
					slot_data[slot_index + x + y * columns] = item
			item.set_init_position(_get_coords_from_slot_index(slot_index))
			item.is_rotated = false
			item.update_visual_rotation()
			item.set_auto_rotated(false)
			return true
		slot_index += 1
	
	# Try rotated orientation
	item.is_rotated = true
	item.update_visual_rotation()
	item.set_auto_rotated(true)
	dims = item.get_dimensions()
	slot_index = 0
	while slot_index < slot_data.size():
		if _item_fits(slot_index, dims):
			for y in dims.y:
				for x in dims.x:
					slot_data[slot_index + x + y * columns] = item
			item.set_init_position(_get_coords_from_slot_index(slot_index))
			return true
		slot_index += 1
	
	# Could not fit
	item.is_rotated = false
	item.update_visual_rotation()
	item.set_auto_rotated(false)
	push_error("Inventory full: Could not add item '%s' (size %dx%d)" %
		[item.data.name, item.data.dimensions.x, item.data.dimensions.y])
	return false

func _item_fits(index: int, dimensions: Vector2i) -> bool:
	for y in dimensions.y:
		for x in dimensions.x:
			var curr_index = index + x + y * columns
			if curr_index >= slot_data.size():
				return false
			if slot_data[curr_index] != null:
				return false
			var split = index / columns != (index + x) / columns
			if split:
				return false
	return true

# Function to get which slot we're clicking on
func _get_slot_index_from_coords(global_coords: Vector2) -> int:
	var local = global_coords - global_position
	var slot = Vector2i(local / SLOT_SIZE)
	
	if slot.x < 0 or slot.y < 0: return -1
	if slot.x >= grid_dimensions.x: return -1
	if slot.y >= grid_dimensions.y: return -1
	
	return slot.x + slot.y * columns

func _get_coords_from_slot_index(index: int) -> Vector2:
	var row = index / columns
	var column = index % columns
	return Vector2(column * SLOT_SIZE, row * SLOT_SIZE)

func _is_mouse_over_grid() -> bool:
	var rect = Rect2(global_position, size)
	return rect.has_point(get_global_mouse_position())

func clear_grid() -> void:
	slot_data.fill(null)
