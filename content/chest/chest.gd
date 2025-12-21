extends Area2D

@onready var interact_label: Label = $InteractLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var chest_inventory_scene: PackedScene

var ui_instance: Control
var player_inside := false

func _ready() -> void:
	interact_label.visible = false
	
	# Animations not to loop
	animation_player.get_animation("open").loop_mode = Animation.LOOP_NONE
	animation_player.get_animation("close").loop_mode = Animation.LOOP_NONE

func _input(event):
	if player_inside and !GameplayState.inventory_open and event.is_action_pressed("interact"):
		toggle_chest()
		GameplayState.inventory_open = true
		animation_player.play("open", 0.0, 1.0)
		
	elif GameplayState.inventory_open and event.is_action_pressed("interact"):
		toggle_chest()
		GameplayState.inventory_open = false
		animation_player.play("close", 0.0, 1.0)

func toggle_chest():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		push_warning("No player found in scene!")
		return
	var player = players[0]

	if ui_instance:
		if ui_instance.has_method("cleanup"):
			ui_instance.cleanup()
		ui_instance.queue_free()
		ui_instance = null
		player.inventory_open = false
	else:
		ui_instance = chest_inventory_scene.instantiate()
		get_tree().root.add_child(ui_instance)
		if ui_instance.has_method("rebuild"):
			ui_instance.rebuild()
		player.inventory_open = true
		
		if ui_instance.has_method("rebuild"):
			ui_instance.rebuild()

func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true
		interact_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false
		interact_label.visible = false
