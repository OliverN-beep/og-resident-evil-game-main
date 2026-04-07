extends Resource
class_name GunResource

@export_group("Identity")
@export var display_name: String

@export_group("Scene")
@export var gun_scene: PackedScene

@export_group("Ammo")
@export var ammo_type: String
@export var magazine_size: int
@export var reload_time: float

@export_group("Ballistics")
@export var bullet_component: BulletComponent
