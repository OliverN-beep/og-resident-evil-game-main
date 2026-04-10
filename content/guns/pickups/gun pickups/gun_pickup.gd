extends Node2D

@export var item_data: ItemData

@onready var outline_sprite: Sprite2D = $outline

var player_ref: Player

var can_interact: bool = false

func _ready() -> void:
	outline_sprite.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact and player_ref:
		
		# Duplicate so each pickup is its own instance
		var new_item: ItemData = item_data
		
		# Add items to inventory
		player_ref.inventory_data.items.append(new_item)
		
		queue_free()

func _on_pickup_area_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		player_ref = body
		outline_sprite.visible = true

func _on_pickup_area_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		player_ref = null
		outline_sprite.visible = false
