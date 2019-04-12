extends TileMap

onready var MapGenUtil = preload("res://utils/MapGen.gd")

var previously_seen_tiles = []
var visible_tiles = []

func connect_entities(entities):
	_update_entities_visibility(entities)
	for entity in entities:
		entity.connect("entity_moved", self, "_on_entity_moved")

func _on_entity_moved(entity):
	if get_parent().entities.has(entity):
		draw_fog_of_war(get_parent().map, get_parent().entities)
	_update_entities_visibility(get_parent().enemy_entities)

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

func _get_visible_tiles_from_positions(positions: Array, map) -> Array:
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
					
					if is_visible and map.get_tile(_transformed_pos) == MapGenUtil.Tiles.WALL:
						_add_shadow_to_line(projection, shadow_line)
						full_shadow = _line_is_full_shadow(shadow_line)
	
	return visible_tiles

func _update_entities_visibility(entities):
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
	
	visible_tiles = _get_visible_tiles_from_positions(positions, map)
	for e in entities:
		visible_tiles.push_back(Vector2(e.gridX, e.gridY))
	for t in visible_tiles:
		if not previously_seen_tiles.has(t):
			previously_seen_tiles.push_back(t)
	for x in range(map.width):
		for y in range(map.height):
			var p = Vector2(x, y)
			if previously_seen_tiles.has(p):
				if visible_tiles.has(p):
					set_cell(x, y, -1)
				else:
					set_cell(x, y, 3)
			else:
				set_cell(x, y, 2)
