extends CPUParticles3D

func _ready() -> void:
	emitting = true

## IF MAKING NEW PARTICLE, CONNECT "finished()" SIGNAL TO CODE
func _on_finished() -> void:
	queue_free()
