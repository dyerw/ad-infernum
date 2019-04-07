extends TileMap

const MapGenUtil = preload("utils/MapGen.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func draw_map(map):
	for x in range(0, map.size()):
		for y in range(0, map[0].size()):
			var tile
			match map[x][y]:
				MapGenUtil.Tiles.FLOOR:
					tile = 33
				MapGenUtil.Tiles.WALL:
					tile = 18
				MapGenUtil.Tiles.MARK:
					tile = 1

			set_cell(x, y, tile)
