extends Control

var isPaused : bool = false

func _input(event):
	if event.is_action_pressed("pause"):
		print("Pausing Game")
		isPaused = !isPaused
		
		get_tree().paused =  isPaused
		if isPaused:
			show()
		else:
			hide()
