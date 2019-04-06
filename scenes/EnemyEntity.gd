extends "res://scenes/Entity.gd"

func _init():
	max_movement_points = 3

func on_click():
	pass

func end_turn():
	var target_path = get_parent().get_path_to_nearest_player_unit(Vector2(self.gridX, self.gridY))
	target_path.remove(target_path.size() - 1)
	print(target_path)
	if target_path.size() > 0:
		.move_along_path(target_path)
	.end_turn()
