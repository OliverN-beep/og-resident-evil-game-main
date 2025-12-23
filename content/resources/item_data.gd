extends Resource
class_name ItemData

@export var name: String
@export var texture: Texture2D
@export var dimensions: Vector2i

# Resource for specific gun
@export var gun_resource: GunResource
# AMMO RESOURCE MUST BE EMPTY/NULL
@export var ammo_resource: AmmoResource

# Runtime ammo count (only used if ammo_resource != null)
@export var ammo_amount: int = 0
@export var loaded_ammo: int = -1
