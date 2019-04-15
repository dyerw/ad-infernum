extends "res://scripts/status/BaseStatus.gd"

var original_attack_points
var original_movement_points

func _init():
	self.display_name = "Stunned"

func apply(_unit):
	self.original_attack_points = _unit.max_attack_points
	self.original_movement_points = _unit.max_movement_points
	_unit.max_attack_points = 0
	_unit.max_movement_points = 0
	.apply(_unit)

func unapply():
	unit.max_attack_points = original_attack_points
	unit.max_movement_points = original_movement_points
	.unapply()