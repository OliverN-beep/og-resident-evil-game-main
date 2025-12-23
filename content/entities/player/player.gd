extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = $Sprite2D
@onready var hearts_ui: Control = $HeartsUI
@onready var health_component: HEALTH_COMPONENT = $Components/HEALTH_COMPONENT

# Declare constants
const MOVE_SPEED: int = 60
const ACCELERATION: int = 5
const FRICTION: int = 8

# Declare variables
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var inventory_open: bool = false

# Inventory
var equipped_gun_item: ItemData
var gun_instance: Node2D

@export_group("Inventory Settings")
# The unique data for this player (Create a Resource file and assign it here!)
@export var inventory_data: InventoryData 
# The UI scene to spawn when pressing 'Tab/Inventory'
@export var player_inventory_scene: PackedScene 

# Track the open UI instance so we can close it later
var inventory_ui_instance: Control = null

func _ready() -> void:
	animation_player.get_animation("Death").loop_mode = Animation.LOOP_NONE
	
	# Make sure UI starts at the right value
	hearts_ui.max_health = health_component.max_health
	hearts_ui.set_health(health_component.current_health)
	
	# Connect signal
	health_component.health_changed.connect(hearts_ui.set_health)

# Physics processes
func _physics_process(delta: float) -> void:
	if !GameplayState.can_act():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_dir: Vector2
	# Assign inputs to directions
	input_dir.x = Input.get_axis("left", "right")
	input_dir.y = Input.get_axis("up", "down")
	
	# Animations based on walk direction
	if input_dir.x:
		animation_player.play("Walk", 0.0, 1.0)
		player_sprite.flip_h = input_dir.x < 0
	elif input_dir.y < 0:
		animation_player.play("Walk up", 0.0, 1.0)
	elif input_dir.y > 0:
		animation_player.play("Walk down", 0.0, 1.0)
	else:
		animation_player.play("Idle", 0.0, 1.0)
	
	# Health Component animations
	if health_component.current_health == 0:
		animation_player.play("Death", 0.0, 1.0)
	
	# Handle knockback
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
	
	var lerp_weight = delta * (ACCELERATION if input_dir else FRICTION)
	velocity = lerp(velocity, input_dir.normalized() * MOVE_SPEED, lerp_weight)
	move_and_slide()

# Testing for healing and taking damage
func _unhandled_input(event):
	# Check the gameplay state first (e.g. if the player is in the inventory)
	if !GameplayState.can_act():
		return
	
	# Healing and damgage
	if event.is_action_pressed("ui_down"):
		health_component.take_damage(health_component.contact_damage)
	if event.is_action_pressed("ui_up"):
		health_component.heal(health_component.heal_amount)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_player_inventory()

func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration

func equip_gun(item: ItemData):
	if item == null or item.gun_resource == null:
		return
	
	# Free old gun
	if gun_instance:
		gun_instance.queue_free()
		gun_instance = null
	
	# Instantiate new gun
	gun_instance = item.gun_resource.gun_scene.instantiate()
	add_child(gun_instance)
	
	# Assign the gun resource to this instance
	if gun_instance.has_method("set_gun_resource"):
		gun_instance.set_gun_resource(item.gun_resource, item)
	
	# Ensure the gun uses the player's inventory
	gun_instance.inventory_data = inventory_data
	
	equipped_gun_item = item
	
	if gun_instance.has_signal("ammo_changed"):
		gun_instance.ammo_changed.connect(_on_gun_ammo_changed)

func toggle_player_inventory():
	if inventory_ui_instance:
		# --- CLOSE INVENTORY ---
		if inventory_ui_instance.has_method("cleanup"):
			inventory_ui_instance.cleanup() # Save data before closing
			
		inventory_ui_instance.queue_free()
		inventory_ui_instance = null
		
		# Resume movement/gameplay
		GameplayState.inventory_open = false 
		inventory_open = false
		
	else:
		if not GameplayState.can_act():
			return 
		
		inventory_ui_instance = player_inventory_scene.instantiate()
		get_tree().root.add_child(inventory_ui_instance)
		
		# INJECT THE DATA
		# We assume the root of your player_inventory_scene has the inventory.gd script
		# or a script that knows how to handle set_dynamic_data
		if inventory_ui_instance.has_method("set_dynamic_data"):
			inventory_ui_instance.set_dynamic_data(inventory_data)
		
		# Pause movement/gameplay
		GameplayState.inventory_open = true
		inventory_open = true

func _on_gun_ammo_changed(new_amount: int) -> void:
	if equipped_gun_item:
		equipped_gun_item.loaded_ammo = new_amount

	# Refresh inventory UI labels
	for ui in get_tree().get_nodes_in_group("inventory_ui"):
		ui.rebuild()
