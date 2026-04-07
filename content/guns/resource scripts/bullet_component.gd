extends Resource
class_name BulletComponent

enum FireMode {
	SEMI,
	AUTO,
	BURST
}

@export var fire_mode: FireMode = FireMode.SEMI

# Core ballistics
@export var bullet_speed: float = 200.0
@export var bullet_duration: float = 1.0
@export var fire_rate: float = 0.3
@export var spawn_offset: float = 0.0

# Pattern
@export var pellet_count: int = 1
@export var base_spread_deg: float = 0.0

# Burst
@export var burst_count: int = 3
@export var burst_interval: float = 0.06

# Recoil
@export var recoil_spread_deg: float = 1.5
@export var recoil_decay_rate: float = 6.0

# Visual / damage
@export var bullet_type: int
@export var bullet_type_array: Array[Texture2D]
@export var damage_per_type := [10, 5, 2, 1]
