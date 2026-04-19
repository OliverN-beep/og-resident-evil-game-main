extends Node

var inventory_open: bool = false
var chest_open: bool = false

func can_act() -> bool:
	return not inventory_open or chest_open
