extends "res://scripts/status/BaseStatus.gd"

func _init():
	self.display_name = "Fervent"

func apply(_unit):
	_unit.strength += 5
	.apply(_unit)

func unapply():
	unit.strength -= 5
	.unapply()