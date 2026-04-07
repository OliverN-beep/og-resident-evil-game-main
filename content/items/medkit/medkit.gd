extends BaseItem

var medkit_heal_amount: int = 1

func use():
	print("MEDKIT USED")
	
	PlayerGlobal.player.health_component.heal(medkit_heal_amount)
	
	queue_free()
