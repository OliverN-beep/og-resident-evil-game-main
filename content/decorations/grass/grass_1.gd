extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.get_animation("sway").loop_mode = Animation.LOOP_NONE

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		animation_player.play("sway", 0.0, 1.2)
