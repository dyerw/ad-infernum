extends "res://scenes/Entity.gd"

var Heal = load("res://scripts/abilities/Heal.gd")

func _ready():
	var heal = Heal.new(self)
	abilities.push_back(heal)
	._ready()
