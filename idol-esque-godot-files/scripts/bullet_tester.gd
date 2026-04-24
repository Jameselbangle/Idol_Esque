extends Enemy

var test : bool = true

func choose_target() -> Vector3:
	return Vector3.ZERO

func _process(delta: float) -> void:
	if test:
		test = false
		var config : Array[BulletConfig] = [BulletConfig.new()]
		
		print("self is: ", self)
		print("has property: ", "enemy_bullet_scene" in self)
		
		Bullet_Factory.circle_formation(self, Vector3.ZERO, 3, 8, config)
		Bullet_Factory.circle_formation(self, Vector3.ZERO, 3.5, 8, config, PI / 8)
		
		shoot()
	
