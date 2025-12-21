class_name HEALTH_COMPONENT
extends Node

# Health system
signal health_changed(new_health)
signal died

@export var max_health: int = 3
@export var contact_damage: int = 1
@export var heal_amount: int = 1

var current_health: int = max_health

# Taking damage
func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	emit_signal("health_changed", current_health)
	if current_health == 0:
		die()

# Healing
func heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, max_health)
	emit_signal("health_changed", current_health)

func die() -> void:
	print("ENTITY DIED")
	emit_signal("died")
