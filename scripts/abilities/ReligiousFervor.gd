extends "res://scripts/abilities/BaseAbility.gd"
const StatusHelper = preload("res://scripts/status/StatusHelper.gd")

func _init(_user_unit).(_user_unit):
	display_name = "Religious Fervor"
	base_cooldown = 10
	targets_self = true

func use(target):
	if current_cooldown == 0:
		StatusHelper.fervent(user_unit, 3)
		.use(target)
