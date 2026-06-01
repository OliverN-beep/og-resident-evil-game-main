extends Area2D

@onready var label: Label = $Label
@onready var sprite_2d: Sprite2D = $Sprite2D

var enabled: bool = false:
	set(value):
		enabled = value
		if label:
			label.visible = value
		# Debug print to track state changes
		print("Interactable enabled: ", enabled)

# Track which bodies are in the area
var bodies_in_area: Array[Node2D] = []

func _ready() -> void:
	# False on spawn
	enabled = false
	
	# Verify collision setup
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	# Only process if this is the key press we care about
	if event.is_action_pressed("interact") and enabled:
		# Only allow interaction if player is in area using groups
		print("Entered door!")
		get_tree().change_scene_to_file("res://content/level gen/level_generation.tscn")

func _on_body_entered(body: Node2D) -> void:
	# Only enable for player
	if body.is_in_group("player"):
		bodies_in_area.append(body)
		enabled = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		bodies_in_area.erase(body)
		# Only disable if player is no longer in area
		if bodies_in_area.is_empty():
			enabled = false
