extends Node2D
class_name World

func _ready():
	add_to_group("world")

func change_room(room_path: String):
	# Remove old room
	for child in $RoomHolder.get_children():
		child.queue_free()

	# Load new room
	var room_scene := load(room_path) as PackedScene
	var room := room_scene.instantiate()
	$RoomHolder.add_child(room)
