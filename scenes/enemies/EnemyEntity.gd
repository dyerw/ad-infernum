extends "res://scenes/Entity.gd"

func _init():
	max_movement_points = 4
	dexterity = 3
	player_controlled = false

func on_click():
	pass

func end_turn(pathing_delegate):
	var target_path = pathing_delegate.get_path_to_nearest_player_unit(self.grid_pos)
	target_path.remove(target_path.size() - 1)
	var cost = 0
	for p in target_path:
		cost += pathing_delegate.get_movement_cost_for_point(p)
	if not cost > max_movement_points * 2:
		var t = current_movement_points
		if target_path.size() > 0:
			yield(.move_along_path(target_path, pathing_delegate), "completed")
		if cost <= current_movement_points:
			.attack(get_parent().get_nearest_player_unit(self.grid_pos), 1)
	
	yield(get_tree(), "idle_frame")
	.end_turn(pathing_delegate)
