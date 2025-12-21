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
var inventory_data: InventoryData
var equipped_gun_item: ItemData
var gun_instance: Node2D

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

func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration

func equip_gun(item: ItemData):
	if item == null or item.gun_resource == null:
		return

	if item.gun_resource.gun_scene == null:
		push_warning("GunResource for '%s' has no gun_scene assigned!" % item.name)
		return

	equipped_gun_item = item

	if gun_instance:
		gun_instance.queue_free()

	gun_instance = item.gun_resource.gun_scene.instantiate()
	add_child(gun_instance)

	if gun_instance.has_method("set_gun_resource"):
		gun_instance.set_gun_resource(item.gun_resource)

	gun_instance.inventory_data = inventory_data
