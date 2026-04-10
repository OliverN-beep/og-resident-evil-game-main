extends Camera2D

const SCREEN_SIZE: Vector2 = Vector2(320, 320)
var current_screen: Vector2 = Vector2(0, 0)

func _ready() -> void:
	top_level = true
	global_position = get_parent().global_position
	_update_screen(current_screen)

func _physics_process(_delta: float) -> void:
	var parent_screen: Vector2 = (get_parent().global_position / SCREEN_SIZE).floor()
	if parent_screen != current_screen:
		_update_screen(parent_screen)

func _update_screen(new_screen: Vector2):
	current_screen = new_screen
	#global_position = SCREEN_SIZE * (current_screen * 0.5)
	global_position = current_screen * SCREEN_SIZE + SCREEN_SIZE * 0.5

func _draw():
	for x in range(-5, 5):
		for y in range(-5, 5):
			var center = Vector2(x, y) * SCREEN_SIZE + SCREEN_SIZE * 0.5
			draw_circle(center, 5, Color.RED)
