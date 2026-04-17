extends Node2D
class_name BaseItem

@onready var pickup_area: Area2D = $PickupArea
@onready var outline_sprite: Sprite2D = $outline

@export var item_data: ItemData

var can_interact: bool = false
var picked_up: bool = false
var holder: Node = null

func _ready() -> void:
	outline_sprite.visible = false
	
	# Connect pickup area signals
	pickup_area.body_entered.connect(_on_pickup_area_body_entered)
	pickup_area.body_exited.connect(_on_pickup_area_body_exited)

func pick_up(player):
	picked_up = true
	
	# Duplicate so each pickup is its own instance
	var new_item: ItemData = item_data
	
	# Initialize runtime values
	if new_item.gun_resource:
		new_item.loaded_ammo = new_item.gun_resource.magazine_size
	
	# Add items to inventory
	player.inventory_data.items.append(new_item)
	
	queue_free()

func use():
	# Override in child item classes (e.g. shotgun, knife, body armour, etc.)
	pass

func _on_pickup_area_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		PlayerGlobal.player = body
		outline_sprite.visible = true

func _on_pickup_area_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		PlayerGlobal.player = null
		outline_sprite.visible = false
