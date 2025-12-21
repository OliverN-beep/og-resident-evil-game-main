extends CharacterBody2D

@onready var player_node: CharacterBody2D = get_parent().get_node("Player")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var enemy_sprite: Sprite2D = $Sprite2D
@onready var health_component: HEALTH_COMPONENT = $Components/HEALTH_COMPONENT
@onready var hearts_ui: Control = $HeartsUI

var should_chase: bool = false

@export var speed: int = 60
@export var knockback_force: int = 100
@export var knockback_duration: float = 0.08

func _ready() -> void:
	animation_player.get_animation("Death").loop_mode = Animation.LOOP_NONE
	
	# Make sure UI starts at the right value
	hearts_ui.max_health = health_component.max_health
	hearts_ui.set_health(health_component.current_health)
	
	# Connect signal
	health_component.health_changed.connect(hearts_ui.set_health)

func _physics_process(delta: float) -> void:
	if should_chase:
		var dir := (player_node.global_position - global_position).normalized()
		velocity = lerp(velocity, dir * speed, 8.5 * delta)
		move_and_slide()
		
		if dir.length() > 0.1:
			animation_player.play("Walk")
			enemy_sprite.flip_h = dir.x < 0
		else:
			animation_player.play("Idle")

func _on_area_2d_body_entered(body: Node) -> void:
	if not body.is_in_group("damageable"):
		return
	
	var target_health := body.get_node_or_null("Components/HEALTH_COMPONENT")
	if target_health:
		print("Enemy hit:", body.name)
		target_health.take_damage(health_component.contact_damage)
	
	should_chase = false
	
	var knockback_direction = (body.global_position - global_position).normalized()
	body.apply_knockback(knockback_direction, knockback_force, knockback_duration)

func _on_enter_area_body_entered(body: Node) -> void:
	if body == player_node:
		should_chase = true

func _on_exit_area_body_exited(body: Node) -> void:
	if body == player_node:
		should_chase = false
		animation_player.play("Idle")
