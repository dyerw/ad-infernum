enum Tiles { FLOOR, WALL }

static func get_movement_cost(tile) -> int:
	match tile:
		Tiles.FLOOR:
			return 1
		Tiles.WALL:
			return 99999
	print(String(tile) + " tile has no movement point value!!!")
	return -1

static func is_passable(tile) -> bool:
	if tile == Tiles.FLOOR:
		return true
	if tile == Tiles.WALL:
		return false
	else:
		return false

static func gen_map(height, width, obstacle_density):
	var map = []
	
	for x in range(0, width + 1):
		var mapColumn = []
		for y in range(0, height + 1):
			if randi() % 5 == 1 and (not y == 0):
				mapColumn.append(Tiles.WALL)
			else:
				mapColumn.append(Tiles.FLOOR)
		map.append(mapColumn)
	
	return map