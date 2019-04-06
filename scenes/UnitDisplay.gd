extends Control

var movement_points_label
var movement_points_bar
var name_label

const BAR_MAX_WIDTH = 60
const BAR_HEIGHT = 10

func clear_entity_details():
	movement_points_label.text = ""
	movement_points_bar.rect_size = Vector2(0, BAR_HEIGHT)

func show_entity_details(entity):
	print(movement_points_bar.rect_size)
	print(entity.display_name)
	name_label.text = entity.display_name
	movement_points_label.text = String(entity.current_movement_points) + "/" + String(entity.max_movement_points)
	movement_points_bar.rect_size = Vector2(
		(entity.current_movement_points / entity.max_movement_points) * BAR_MAX_WIDTH,
		BAR_HEIGHT
	)
	print(movement_points_bar.rect_size)

func _ready():
	movement_points_label = get_node("UnitDisplayContainer/MovementPointsLabel")
	movement_points_bar = get_node("UnitDisplayContainer/MovementBar")
	name_label = get_node("UnitDisplayContainer/NameLabel")

