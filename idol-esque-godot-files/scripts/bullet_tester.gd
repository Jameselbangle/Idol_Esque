extends Enemy

var test : bool = true

func choose_target() -> Vector3:
	return Vector3.ZERO

func _process(delta: float) -> void:
	if test:
		test = false
		var config : Array[BulletConfig] = [BulletConfig.new()]
		config[0].tick_timer = 60
		
		var con2 : BulletConfig = BulletConfig.new()
		con2.speed = 0.1
		con2.direction = Vector3.RIGHT
		con2.tick_timer = 60
		config.append(con2)
		
		Bullet_Factory.circle_formation(self, Vector3.ZERO, 1, 8, config)
		Bullet_Factory.circle_formation(self, Vector3.ZERO, 2, 8, config, PI / 8)
		
		shoot()
	
