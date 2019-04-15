extends "res://scenes/Entity.gd"

var ReligiousFervor = load("res://scripts/abilities/ReligiousFervor.gd")

func _ready():
	var religious_fervor = ReligiousFervor.new(self)
	abilities.push_back(religious_fervor)
	._ready()
