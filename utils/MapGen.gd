enum Tiles { FLOOR, WALL }

static func gen_map(height, width, obstacle_density):
	var map = []
	
	for x in range(0, width + 1):
		var mapColumn = []
		for y in range(0, height + 1):
			mapColumn.append(Tiles.FLOOR)
		map.append(mapColumn)
	
	return map