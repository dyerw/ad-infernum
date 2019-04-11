extends Control

var movement_points_label
var name_label
var health_points_label
var dex_points_label
var attack_points_label
var str_points_label
var evd_points_label

const BAR_MAX_WIDTH = 60
const BAR_HEIGHT = 10

func clear_entity_details():
	name_label.text = "No one selected"
	movement_points_label.text = ""
	health_points_label.text = ""
	dex_points_label.text = ""
	attack_points_label.text = ""
	str_points_label.text = ""
	evd_points_label.text = ""

func show_entity_details(entity):
	name_label.text = entity.display_name
	dex_points_label.text = String(entity.dexterity)
	str_points_label.text = String(entity.strength)
	evd_points_label.text = String(entity.evade)
	health_points_label.text = String(entity.current_health) + "/" + String(entity.max_health)
	movement_points_label.text = String(entity.current_movement_points) + "/" + String(entity.max_movement_points)
	attack_points_label.text = String(entity.current_attack_points) + "/" + String(entity.max_attack_points)


func _ready():
	movement_points_label = get_node("UnitDisplayContainer/MovementPointsLabel")
	name_label = get_node("UnitDisplayContainer/NameLabel")
	health_points_label = get_node("UnitDisplayContainer/HealthPointsLabel")
	dex_points_label = get_node("UnitDisplayContainer/DexContainer/DexPointsLabel")
	attack_points_label = get_node("UnitDisplayContainer/AttackPointsLabel")
	evd_points_label = get_node("UnitDisplayContainer/EvdContainer/EvdPointsLabel")
	str_points_label = get_node("UnitDisplayContainer/StrContainer/StrPointsLabel")
	
	name_label.text = "No one selected"

func _on_EndTurnButton_pressed():
	get_parent().end_turn_button_pressed()
