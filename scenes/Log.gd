extends Control

var log_label

func add_line(line):
	log_label.text = log_label.text + "\n" + line

func _ready():
	log_label = get_node("LogLabel")

