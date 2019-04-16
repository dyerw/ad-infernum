extends "res://scripts/abilities/BaseAbility.gd"

func _init(_user_unit).(_user_unit):
	display_name = "Heal"
	base_cooldown = 10
	targets_self = false

func use(target):
	if current_cooldown == 0:
		target.heal(3)
		.use(target)