extends Control

@onready var hearts_container: HBoxContainer = $HBoxContainer

var max_health: int
var current_health: int = max_health

var heart_full: Texture = preload("res://content/UI/misc/health/heart.png")
var heart_empty: Texture = preload("res://content/UI/misc/health/empty heart.png")

var health_component: HEALTH_COMPONENT

func _ready():
	update_hearts()

func update_hearts():
	# Clear existing hearts
	for child in hearts_container.get_children():
		child.queue_free()
	
	for i in range(max_health):
		var heart = TextureRect.new()
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		if i < current_health:
			heart.texture = heart_full
		else:
			heart.texture = heart_empty
		
		hearts_container.add_child(heart)

func set_health(new_health: int):
	current_health = clamp(new_health, 0, max_health)
	update_hearts()
