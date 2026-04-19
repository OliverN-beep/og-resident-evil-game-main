extends CanvasLayer

func _ready() -> void:
	visible = false

func _on_retry_pressed() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	print("Retry pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
