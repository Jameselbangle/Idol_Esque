extends Enemy

func choose_target() -> Vector3:
	return Vector3.ZERO

func choose_target_position() -> Vector3:
	var options = [
		Vector3(2.5, 0, 2.5),
		Vector3(2.5, 0, -2.5),
		Vector3(-2.5, 0, 2.5),
		Vector3(-2.5, 0, -2.5),
		Vector3.ZERO
	]
	return options[randi() % options.size()]
	
func _ready() -> void:
	patterns.append(burst_shot)
	
func burst_shot(_target : Vector3):
	var config : Array[BulletConfig] = [BulletConfig.new()]
	
	config[0].speed = 2
	config[0].movement_type = BulletConfig.MoveFunction.LINEAR
	config[0].direction = (_target - position).normalized()
	config[0].direction.y = 0
	
	if (config[0].direction == Vector3.ZERO): return
	
	config[0].tick_timer = 600
	
	Bullet_Factory.line_formation(self, Vector3.ZERO, config[0].direction * 2, 3, config)
	
	shoot()
