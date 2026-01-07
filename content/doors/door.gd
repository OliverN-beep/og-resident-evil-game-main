extends Area2D

class_name Door

@export var connected_room: String

@export var player_pos: Vector2

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		RoomChangeGlobal.Activate = true
		RoomChangeGlobal.player_pos = player_pos
		
		var world := get_tree().get_first_node_in_group("world")
		world.call_deferred("change_room", connected_room)
