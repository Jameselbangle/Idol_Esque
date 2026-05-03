extends Enemy

func choose_target() -> Vector3:
	
	var targets = get_tree().get_nodes_in_group("players")
	assert(!targets.is_empty(), "'players' group is empty")
	
	var current_target
	
	for i in targets:
		if current_target == null:
			if (i.is_dead): continue
			current_target = i
		
		if position.distance_to(i.position) < position.distance_to(current_target.position):
			if (i.is_dead): continue
			current_target = i
	
	if current_target == null: return Vector3.ZERO
	return current_target.position

func choose_target_position() -> Vector3:

	return choose_target()

func _ready() -> void:
	patterns.append(circle_burst)
	set_shield(BulletConfig.BulletColour.ENEMY)

func circle_burst(_target):
	var config : Array[BulletConfig] = [BulletConfig.new()]

	config[0].speed = -2
	config[0].movement_type = BulletConfig.MoveFunction.TARGET
	config[0].target = position
	config[0].tick_timer = 600
	
	Bullet_Factory.circle_formation(self, Vector3.ZERO, 1, 8, config)
	
	shoot()
