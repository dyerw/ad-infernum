enum Tiles { FLOOR, WALL }

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