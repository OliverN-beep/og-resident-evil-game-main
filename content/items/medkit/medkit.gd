extends WorldPickup

var medkit_heal_amount: int = 1

func use():
	print("MEDKIT USED")
	
	if PlayerGlobal.player == null:
		print("NO PLAYER FOUND")
		return
	
	if PlayerGlobal.player.health_component == null:
		print("NO HEALTH COMPONENT")
		return
	
	PlayerGlobal.player.health_component.heal(medkit_heal_amount)
