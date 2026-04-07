extends Sprite2D
class_name InventoryItem

const SLOT_SIZE = 64

@onready var stack_label: Label = $StackLabel
@onready var buttonmenu: VBoxContainer = $buttonmenu

var data: ItemData
var is_picked := false
var base_dimensions: Vector2i
var auto_rotated := false
var holder: Node = null

static var open_menu: InventoryItem = null

var size: Vector2:
	get():
		var dims := get_dimensions()
		return Vector2(dims.x, dims.y) * SLOT_SIZE

var anchor_point: Vector2:
	get():
		return global_position - size / 2.0

func _ready() -> void:
	if data.dimensions == Vector2i.ZERO:
		push_warning("Item '%s' has no dimensions, defaulting to 1x1" % data.name)
		data.dimensions = Vector2i(1, 1)
	
	base_dimensions = data.dimensions
	texture = data.texture
	rotation_degrees = 0
	_update_stack_label()
	
	buttonmenu.visible = false

func _update_stack_label() -> void:
	# AMMO STACKS
	if data.ammo_resource != null:
		stack_label.text = str(data.ammo_amount)
		return
	
	# GUN MAGAZINE
	if data.gun_resource != null:
		var mag_size := data.gun_resource.magazine_size
		
		if data.loaded_ammo < 0:
			stack_label.text = "%d" % [mag_size]
		else:
			stack_label.text = "%d" % [data.loaded_ammo]
		return
	
	stack_label.text = ""

func _process(_delta: float) -> void:
	if is_picked:
		global_position = get_global_mouse_position()

func set_init_position(pos: Vector2) -> void:
	position = pos + size / 2  # local position relative to parent (GridContainer)

func get_picked_up() -> void:
	add_to_group("held_item")
	is_picked = true
	z_index = 10
	set_auto_rotated(false)

func get_placed(pos: Vector2i) -> void:
	if data.is_rotated:
		rotation_degrees = 90.0
	else:
		rotation_degrees = 0.0
	
	position = pos + Vector2i(size / 2)
	z_index = 0
	remove_from_group("held_item")
	is_picked = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		# Right click to rotate while dragging
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if is_picked:
				
				do_rotation()
				_close_menu()
				return
		
			if open_menu and open_menu != self:
				open_menu._close_menu()
			
			if buttonmenu.visible:
				_close_menu()
			else:
				_open_menu()

func _try_select() -> void:
	if !data:
		print("item_data not found, selection failed")
		return
	
	if data.gun_resource == null:
		return
	
	# Only equip if parented to the player's inventory grid
	var player_inventory := get_tree().get_first_node_in_group("player_inventory_grid")
	if get_parent() != player_inventory:
		return
	
	get_tree().call_group("player", "equip_gun", data)

func do_rotation() -> void:
	data.is_rotated = !data.is_rotated
	update_visual_rotation()

func reparent_to_inventory(inventory_ui: Node) -> void:
	# inventory_ui should be the GridContainer
	if get_parent() != inventory_ui:
		var prev_global := global_position
		get_parent().remove_child(self)
		inventory_ui.add_child(self)
		global_position = prev_global

func get_anchor_point() -> Vector2:
	return anchor_point

func get_dimensions() -> Vector2i:
	return Vector2i(base_dimensions.y, base_dimensions.x) if data.is_rotated else base_dimensions

# Function for updating the rotation of the sprite visually
# Example use is for rotating items that are too big to fit initially
func update_visual_rotation() -> void:
	if data.is_rotated:
		rotation_degrees = 90.0
	else:
		rotation_degrees = 0.0

# Function to add a tint to items that have automatically been rotated
func set_auto_rotated(rotated: bool) -> void:
	auto_rotated = rotated
	if auto_rotated:
		modulate = Color(1, 1, 0.5, 1) # Slight yellow tint
	else:
		modulate = Color(1, 1, 1, 1)   # Reset to normal

func _on_drop_pressed() -> void:
	print("DROPPED")

func _on_use_pressed() -> void:
	_try_select()
	print("USED")

func _open_menu():
	buttonmenu.visible = true
	open_menu = self

func _close_menu():
	buttonmenu.visible = false
	if open_menu == self:
		open_menu = null
