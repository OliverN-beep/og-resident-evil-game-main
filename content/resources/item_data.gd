extends Resource
class_name ItemData

@export var name: String
@export var texture: Texture2D
@export var dimensions: Vector2i

# Optional links
@export var gun_resource: GunResource
@export var ammo_resource: AmmoResource

# Runtime ammo count (only used if ammo_resource != null)
@export var ammo_amount: int = 0
