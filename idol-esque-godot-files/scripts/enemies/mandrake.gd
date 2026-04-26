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
	patterns.append(circle_burst)

func circle_burst():
	var config : Array[BulletConfig] = [BulletConfig.new()]

	config[0].speed = -2
	config[0].movement_type = BulletConfig.MoveFunction.TARGET
	config[0].target = position
	config[0].tick_timer = 600
	
	Bullet_Factory.circle_formation(self, Vector3.ZERO, 1, 8, config)
	
	shoot()
