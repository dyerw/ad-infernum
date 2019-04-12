extends TileMap

const MapGenUtil = preload("utils/MapGen.gd")

const FLOOR_TILE = 1
const WALL_TILE = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func draw_map(map):
	for x in range(map.size()):
		for y in range(map[0].size()):
			var tile
			match map[x][y]:
				MapGenUtil.Tiles.FLOOR:
					tile = FLOOR_TILE
				MapGenUtil.Tiles.WALL:
					tile = WALL_TILE
				MapGenUtil.Tiles.MARK:
					tile = 1

			set_cell(x, y, tile)
