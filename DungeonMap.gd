extends TileMap

const MapGenUtil = preload("utils/MapGen.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func draw_map(map):
	for x in range(0, map.size() - 1):
		for y in range(0, map[0].size() - 1):
			var tile
			if map[x][y] == MapGenUtil.Tiles.FLOOR:
				tile = 33
			else:
				tile = 18
			set_cell(x, y, tile)
