extends AudioStreamPlayer

var timer

func _ready():
	timer = get_node("AudioTimer")

func play_audio():
	self.play()
	timer.start(2)

func _on_AudioTimer_timeout():
	self.stop()
