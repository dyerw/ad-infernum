extends Area2D

func _ready():
	pass

func _input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
        get_parent().on_click()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
