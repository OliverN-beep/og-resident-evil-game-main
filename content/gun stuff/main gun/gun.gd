extends Node2D

const bullet_scene = preload("res://content/bullets/bullet.tscn")

@onready var rotation_offset: Node2D = $RotationOffset
@onready var torchlight: PointLight2D = $RotationOffset/torchlight
@onready var shoot_timer: Timer = $ShootTimer

signal ammo_changed(current: int)

# Booleans
var can_shoot := true
var torchlight_on := false

# Recoil
var recoil := 0.0

# Resources
var gun_resource: GunResource
var bullet_component: BulletComponent
var inventory_data: InventoryData

# Ammo stuff
var current_ammo := 0
var is_reloading := false

var gun_item_data: ItemData

func _ready() -> void:
	torchlight.visible = false

func set_gun_resource(res: GunResource, item_data: ItemData) -> void:
	gun_resource = res
	gun_item_data = item_data

	bullet_component = res.bullet_component.duplicate() as BulletComponent
	shoot_timer.wait_time = bullet_component.fire_rate
	recoil = 0.0
	is_reloading = false

	if gun_item_data.loaded_ammo >= 0:
		current_ammo = gun_item_data.loaded_ammo
	else:
		current_ammo = res.magazine_size
		gun_item_data.loaded_ammo = current_ammo

func _physics_process(delta: float) -> void:
	# Safety to prevent crashes
	if bullet_component == null:
		return
	
	# Check the gameplay state
	if !GameplayState.can_act():
		return
	
	# Recoil decay
	recoil = max(recoil - bullet_component.recoil_decay_rate * delta, 0.0)
	
	rotation_offset.rotation = lerp_angle(
		rotation_offset.rotation, (get_global_mouse_position() - global_position).angle(), 6.5 * delta)
	
	var wants_to_fire := false
	
	match bullet_component.fire_mode:
		BulletComponent.FireMode.SEMI:
			wants_to_fire = Input.is_action_just_pressed("shoot")
		BulletComponent.FireMode.AUTO:
			wants_to_fire = Input.is_action_pressed("shoot")
		BulletComponent.FireMode.BURST:
			wants_to_fire = Input.is_action_just_pressed("shoot")

	if wants_to_fire and can_shoot:
		_fire_weapon()
	
	if Input.is_action_just_pressed("reload"):
		_try_reload()
		print ("reload pressed")
	
	if Input.is_action_just_pressed("torchlight"):
		torchlight_on = !torchlight_on
		torchlight.visible = torchlight_on

func _shoot():
	var base_dir := Vector2.RIGHT.rotated(rotation_offset.global_rotation)
	
	var pellets: int = max(1, bullet_component.pellet_count)
	var spread := deg_to_rad(bullet_component.spread_angle_deg)
	
	for i in pellets:
		var bullet := bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		
		var angle_offset: float
		
		if pellets == 1:
			# SMG / pistol: random in cone
			angle_offset = randf_range(-spread * 0.5, spread * 0.5)
		else:
			# Shotgun: even spread
			var t := float(i) / float(pellets - 1)
			angle_offset = lerp(-spread * 0.5, spread * 0.5, t)
		
		var dir := base_dir.rotated(angle_offset)
		
		bullet.global_position = global_position + dir * bullet_component.spawn_offset
		bullet.global_rotation = dir.angle()
		
		bullet.apply_bullet_component(bullet_component, dir)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _fire_weapon():
	if is_reloading:
		return

	if current_ammo <= 0:
		print("Out of ammo")
		return
	
	can_shoot = false
	current_ammo -= 1
	ammo_changed.emit(current_ammo)
	
	match bullet_component.fire_mode:
		BulletComponent.FireMode.BURST:
			_fire_burst()
		_:
			_shoot_once()
	
	shoot_timer.start()
	
	shoot_timer.start()
	
	if gun_item_data:
		gun_item_data.loaded_ammo = current_ammo

func _fire_burst():
	for i in bullet_component.burst_count:
		_shoot_once()
		await get_tree().create_timer(bullet_component.burst_interval).timeout

func _shoot_once():
	if bullet_component == null:
		push_error("BulletComponent missing on gun instance!")
		return
	
	var base_dir := Vector2.RIGHT.rotated(rotation_offset.global_rotation)
	
	var spread := deg_to_rad(
		bullet_component.base_spread_deg +
		recoil * bullet_component.recoil_spread_deg
	)
	
	var pellets: int = max(1, bullet_component.pellet_count)
	
	for i in pellets:
		var bullet := bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		
		var angle_offset: float
		
		if pellets == 1:
			angle_offset = randf_range(-spread * 0.5, spread * 0.5)
		else:
			var t := float(i) / float(pellets - 1)
			angle_offset = lerp(-spread * 0.5, spread * 0.5, t)
		
		var dir := base_dir.rotated(angle_offset)
		
		bullet.global_position = global_position + dir * bullet_component.spawn_offset
		bullet.global_rotation = dir.angle()
		bullet.apply_bullet_component(bullet_component, dir)
	
	# Recoil increases per shot
	recoil += 1.0

func _try_reload():
	if is_reloading:
		return

	if current_ammo >= gun_resource.magazine_size:
		return

	if inventory_data == null:
		return

	if not inventory_data.has_ammo(gun_resource.ammo_type):
		return
	
	_reload()
	
	print("Reload pressed. Has ammo:",
		inventory_data.has_ammo(gun_resource.ammo_type),
		"Current:", current_ammo
	)

func _reload():
	is_reloading = true
	await get_tree().create_timer(gun_resource.reload_time).timeout

	var needed: int = gun_resource.magazine_size - current_ammo
	if needed <= 0:
		is_reloading = false
		return

	var taken: int = inventory_data.take_ammo(
		gun_resource.ammo_type,
		needed
	)

	if taken <= 0:
		is_reloading = false
		return

	current_ammo += taken

	if gun_item_data:
		gun_item_data.loaded_ammo = current_ammo

	is_reloading = false
	ammo_changed.emit(current_ammo)

func setup_from_item(item_data: ItemData):
	gun_item_data = item_data
	gun_resource = item_data.gun_resource

	if item_data.loaded_ammo < 0:
		current_ammo = gun_resource.magazine_size
		item_data.loaded_ammo = current_ammo
	else:
		current_ammo = item_data.loaded_ammo
