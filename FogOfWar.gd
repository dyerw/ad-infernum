extends TileMap

onready var MapGenUtil = preload("res://utils/MapGen.gd")

var previously_seen_tiles = []
var visible_tiles = []

func _transform_octant(row: int, col: int, octant: int) -> Vector2:
	match octant:
		0: return Vector2(col, -row)
		1: return Vector2(row, -col)
		2: return Vector2(row, col)
		3: return Vector2(col, row)
		4: return Vector2(-col, row)
		5: return Vector2(-row, col)
		6: return Vector2(-row, -col)
		7: return Vector2(-col, -row)
	print("You fucked up in _transform_octant")
	return Vector2(0, 0)

func _get_tiles_in_octant(origin, max_distance):
	var positions = []
	for x in range(1, max_distance):
		for y in range(x + 1):
			var pos = Vector2(origin.x + y, origin.y - x)
			positions.push_back(pos)
	return positions

# Shadow, Shadow -> bool
func _shadow_contains(first: Vector2, second: Vector2) -> bool:
	return first.x <= second.x and first.y >= second.y

func _shadow_line_contains(line: Array, projection: Vector2) -> bool:
	for shadow in line:
		if _shadow_contains(shadow, projection):
			return true
	return false

func _project_tile(row: int, col: int) -> Vector2:
	var top_left = float(col) / (float(row) + 2.0)
	var bottom_right = (float(col) + 1.0) / (float(row) + 1.0)
	return Vector2(top_left, bottom_right)

func _add_shadow_to_line(shadow: Vector2, line: Array) -> void:
	var index = 0
	while index < line.size():
		if line[index].x >= shadow.x:
			break
		index += 1
	
	var overlapping_previous
	if index > 0 and line[index - 1].y > shadow.x:
		overlapping_previous = line[index - 1]
	
	var overlapping_next
	if index < line.size() and line[index].x < shadow.y:
		overlapping_next = line[index]
	
	if overlapping_next:
		if overlapping_previous:
			var new_shadow = Vector2(overlapping_previous.x, overlapping_next.y)
			overlapping_previous.y = overlapping_next.y
			line.remove(index)
			line.remove(index - 1)
			line.insert(index - 1, new_shadow)
		else:
			var new_shadow = Vector2(shadow.x, overlapping_next.y)
			line.remove(index)
			line.insert(index, new_shadow)
	else:
		if overlapping_previous:
			overlapping_previous.y = shadow.y
			var new_shadow = Vector2(overlapping_previous.x, shadow.y)
			line.remove(index - 1)
			line.insert(index - 1, new_shadow)
		else:
			line.insert(index, shadow)

func _line_is_full_shadow(line):
	return line.size() == 1 and line[0].x == 0 and line[0].y == 1

func _get_visble_tiles_from_positions(positions: Array, map) -> Array:
	var visible_tiles = []
	for pos in positions:
		visible_tiles += _get_visible_tiles(pos, map)
	return visible_tiles

func _get_visible_tiles(pos: Vector2, map) -> Array:
	var visible_tiles = [pos]
	
	for octant in range(8):
		var shadow_line: Array = [] # :: Array Vector2
		var full_shadow = false
	
		for row in range(10000):
			var transformed_pos = pos + _transform_octant(row, 0, octant)
			if not MapGenUtil.is_in_bounds(transformed_pos, map):
				break
	
			for col in range(row + 1):
				var _transformed_pos = pos + _transform_octant(row, col, octant)
				
				if not MapGenUtil.is_in_bounds(_transformed_pos, map):
					break
				
				if full_shadow:
					continue
				else:
					var projection = _project_tile(row, col)
					
					var is_visible = not _shadow_line_contains(shadow_line, projection)
					if is_visible:
						visible_tiles.push_back(_transformed_pos)
					
					if is_visible and map[_transformed_pos.x][_transformed_pos.y] == MapGenUtil.Tiles.WALL:
						_add_shadow_to_line(projection, shadow_line)
						full_shadow = _line_is_full_shadow(shadow_line)
	
	return visible_tiles
	

func _line_intersects_tile(from: Vector2, to: Vector2, tile: Vector2) -> bool:
	# Check if it hits the sides of a tile
	if Geometry.segment_intersects_segment_2d(from, to, tile, Vector2(tile.x + 1, tile.y)):
		return true
	if Geometry.segment_intersects_segment_2d(from, to, tile, Vector2(tile.x + 1, tile.y + 1)):
		return true
	if Geometry.segment_intersects_segment_2d(from, to, tile, Vector2(tile.x, tile.y + 1)):
		return true
	return false

func _tiles_visible_from_entity(map, entity, walls):
	var visible_tiles = []
	
	var entity_center_point = Vector2(entity.gridX + 0.5, entity.gridY + 0.5)
	for x in map.size():
		for y in map[x].size():
			var p = Vector2(x + 0.5, y + 0.5)
			var is_visible = true
			for wall_tile in walls:
				if not wall_tile == Vector2(x, y):
					if _line_intersects_tile(entity_center_point, p, wall_tile):
						is_visible = false
			if is_visible:
				visible_tiles.push_back(Vector2(x, y))
	return visible_tiles

func _get_tiles_visible_from_entities(map, entities):
	var visible_tiles = []
	var walls = []
	for x in range(map.size()):
		for y in range(map[x].size()):
			if map[x][y] == MapGenUtil.Tiles.WALL:
				walls.push_back(Vector2(x, y))
	for entity in entities:
		for tile in _tiles_visible_from_entity(map, entity, walls):
			if not visible_tiles.has(tile):
				visible_tiles.push_back(tile)
	return visible_tiles

func hide_entities(entities):
	for e in entities:
		var entity_pos = Vector2(e.gridX, e.gridY)
		if visible_tiles.has(entity_pos):
			e.visible = true
		else:
			e.visible = false

func draw_fog_of_war(map, entities):
	var positions = []
	for e in entities:
		positions.push_back(Vector2(e.gridX, e.gridY))
	
	visible_tiles = _get_visble_tiles_from_positions(positions, map)
	previously_seen_tiles += visible_tiles
	for x in range(map.size()):
		for y in range(map[x].size()):
			if not previously_seen_tiles.has(Vector2(x, y)):
				set_cell(x, y, 2)
			else:
				set_cell(x, y, -1)
