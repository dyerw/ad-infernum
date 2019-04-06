extends "res://scenes/Entity.gd"

func _init():
	max_movement_points = 3
	dexterity = 2

func on_click():
	pass

func end_turn(pathing_delegate):
	var target_path = get_parent().get_path_to_nearest_player_unit(Vector2(self.gridX, self.gridY))
	if target_path: 
		target_path.remove(target_path.size() - 1)
		if target_path.size() > 0:
			.move_along_path(target_path, pathing_delegate)
		else:
			.attack(get_parent().get_nearest_player_unit(Vector2(self.gridX, self.gridY)), 1)
	.end_turn(pathing_delegate)
