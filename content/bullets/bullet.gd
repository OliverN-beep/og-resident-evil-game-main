extends Area2D
class_name Bullet

@onready var sprite: Sprite2D = $Sprite2D

var velocity := Vector2.ZERO
var damage := 0
var lifetime := 0.0

func _ready() -> void:
	set_physics_process(false) # disabled until configured

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func apply_bullet_component(bc: BulletComponent, dir: Vector2) -> void:
	var direction := dir.normalized()
	
	velocity = direction * bc.bullet_speed
	damage = bc.damage_per_type[bc.bullet_type]
	lifetime = bc.bullet_duration
	
	if sprite and bc.bullet_type < bc.bullet_type_array.size():
		sprite.texture = bc.bullet_type_array[bc.bullet_type]
	
	set_physics_process(true)
