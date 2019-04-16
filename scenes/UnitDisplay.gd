extends Control

var statuses_label
var movement_points_label
var name_label
var health_points_label
var dex_points_label
var attack_points_label
var str_points_label
var evd_points_label
var will_points_label

var ability_button_container

const BAR_MAX_WIDTH = 60
const BAR_HEIGHT = 10

func foo():
	print("foo")

func clear_entity_details():
	remove_unit_ability_buttons()
	name_label.text = "No one selected"
	movement_points_label.text = ""
	health_points_label.text = ""
	dex_points_label.text = ""
	attack_points_label.text = ""
	str_points_label.text = ""
	evd_points_label.text = ""
	will_points_label.text = ""
	statuses_label.text = ""

func remove_unit_ability_buttons():
	for i in range(0, ability_button_container.get_child_count()):
    	ability_button_container.get_child(i).queue_free()

func render_unit_ability_buttons(unit):
	for ability in unit.abilities:
		var ability_button = Button.new()
		ability_button.text = ability.display_name + " " + String(ability.current_cooldown)
		if ability.targets_self:
			ability_button.connect("pressed", ability, "use", [null])
		else:
			ability_button.connect("pressed", get_parent(), "targeting_with_ability", [ability])
		ability_button_container.add_child(ability_button)

func show_entity_details(entity):
	name_label.text = entity.display_name
	
	remove_unit_ability_buttons()
	render_unit_ability_buttons(entity)
	
	var statuses_string = ""
	for status in entity.statuses:
		statuses_string += (status.display_name + " " + String(status.duration_left) + ", ")
	statuses_label.text = statuses_string
	
	dex_points_label.text = String(entity.dexterity)
	str_points_label.text = String(entity.strength)
	evd_points_label.text = String(entity.evade)
	will_points_label.text = String(entity.willpower)
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
	will_points_label = get_node("UnitDisplayContainer/WillContainer/WillPointsLabel")
	statuses_label = get_node("UnitDisplayContainer/StatusesLabel")
	ability_button_container = get_node("UnitDisplayContainer/AbilityButtonContainer")
	
	name_label.text = "No one selected"

func _on_EndTurnButton_pressed():
	get_parent().end_turn_button_pressed()
