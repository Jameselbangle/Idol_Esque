extends Enemy

var first_press := true

func choose_target() -> Vector3:
	return Vector3.ZERO

func choose_target_position() -> Vector3:
	return Vector3.ZERO

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE) and first_press:
		first_press = false
		
		var config : Array[BulletConfig] = [BulletConfig.new()]
	
		config[0].speed = 2
		config[0].movement_type = BulletConfig.MoveFunction.LINEAR
		config[0].direction = (Vector3(1, 0, 3) - position).normalized()
		config[0].direction.y = 0
		config[0].tick_timer = 600
	
		Bullet_Factory.line_formation(self, Vector3.ZERO, config[0].direction * 2, 3, config)
	
		shoot()
	
	if !Input.is_key_pressed(KEY_SPACE):
		first_press = true
	
