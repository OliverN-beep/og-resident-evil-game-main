extends Node

var inventory_open := false
var chest_open := false

func can_act() -> bool:
	return not inventory_open or chest_open
