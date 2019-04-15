var base_cooldown
var current_cooldown
var user_unit

signal ability_used

var display_name = "Base Ability"

func _init(_user_unit):
	user_unit = _user_unit
	current_cooldown = 0

func use(target):
	current_cooldown = base_cooldown - user_unit.willpower
	emit_signal("ability_used")

func end_turn():
	if current_cooldown > 0:
		current_cooldown -= 1