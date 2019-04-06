extends Control

var movement_points_label
var movement_points_bar
var name_label
var health_points_label
var dex_points_label

const BAR_MAX_WIDTH = 60
const BAR_HEIGHT = 10

func clear_entity_details():
	name_label.text = "No one selected"
	movement_points_label.text = ""
	health_points_label.text = ""
	dex_points_label.text = ""
	movement_points_bar.rect_size = Vector2(0, BAR_HEIGHT)

func show_entity_details(entity):
	name_label.text = entity.display_name
	dex_points_label.text = String(entity.dexterity)
	health_points_label.text = String(entity.current_health) + "/" + String(entity.max_health)
	movement_points_label.text = String(entity.current_movement_points) + "/" + String(entity.max_movement_points)
	movement_points_bar.rect_size = Vector2(
		(entity.current_movement_points / entity.max_movement_points) * BAR_MAX_WIDTH,
		BAR_HEIGHT
	)

func _ready():
	movement_points_label = get_node("UnitDisplayContainer/MovementPointsLabel")
	movement_points_bar = get_node("UnitDisplayContainer/MovementBar")
	name_label = get_node("UnitDisplayContainer/NameLabel")
	health_points_label = get_node("UnitDisplayContainer/HealthPointsLabel")
	dex_points_label = get_node("UnitDisplayContainer/DexContainer/DexPointsLabel")
	
	name_label.text = "No one selected"

func _on_EndTurnButton_pressed():
	get_parent().end_turn_button_pressed()
