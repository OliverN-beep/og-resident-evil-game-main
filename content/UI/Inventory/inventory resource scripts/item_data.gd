extends Resource
class_name ItemData

@export var name: String
@export var texture: Texture2D
@export var dimensions: Vector2i

# Resource for specific gun
@export var gun_resource: GunResource
# AMMO RESOURCE MUST BE EMPTY/NULL
@export var ammo_resource: AmmoResource

# Item description
@export_multiline("monospace") var item_description: String

@export var item_script: Script

@export var grid_index: int = -1
@export var is_rotated: bool = false
@export var ammo_amount: int = 0
@export var loaded_ammo: int = -1
