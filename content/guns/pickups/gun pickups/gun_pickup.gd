extends Node2D

@export var item_data: ItemData

@onready var outline_sprite: Sprite2D = $outline

var can_interact: bool = false

func _ready() -> void:
	outline_sprite.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact and PlayerGlobal.player:
		
		# Duplicate so each pickup is its own instance
		var new_item: ItemData = item_data
		
		# Initialize runtime values
		if new_item.gun_resource:
			new_item.loaded_ammo = new_item.gun_resource.magazine_size
		
		# Add items to inventory
		PlayerGlobal.player.inventory_data.items.append(new_item)
		
		queue_free()

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
