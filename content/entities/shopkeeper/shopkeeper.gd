extends CharacterBody2D

@onready var shop_ui: CanvasLayer = $ShopUI

var player_ref: Player

var is_interactable: bool = false

func _ready() -> void:
	shop_ui.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_interactable:
		if !shop_ui.visible:
			shop_ui.visible = true
		else:
			shop_ui.visible = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_interactable = true
		player_ref = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_interactable = false
		shop_ui.visible = false
		player_ref = null
