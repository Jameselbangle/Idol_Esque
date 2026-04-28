extends Enemy

func choose_target() -> Vector3:
	#TODO: Consider caching targets
	var targets = get_tree().get_nodes_in_group("players")
	assert(!targets.is_empty(), "'players' group is empty")
	
	var current_target = targets[0]
	
	for i in targets:
		if i.is_dead:
			pass
		if position.distance_to(i.position) < position.distance_to(current_target.position):
			current_target = i
	return current_target.position

func choose_target_position() -> Vector3:
	var closest_target : Vector3 = choose_target()
	var distance = position.distance_to(closest_target)
	#print(distance)
	if distance < 2:
		var direction : Vector3  = (position - closest_target).normalized()
		direction *= 4
		return position + direction
	if distance > 6:
		var direction : Vector3  = (position - closest_target).normalized()
		direction *= 4
		return position - direction
	
	return position

func _ready() -> void:
	patterns.append(burst_shot)
	
func burst_shot(_target : Vector3):
	var config : Array[BulletConfig] = [BulletConfig.new()]
	
	config[0].speed = 2
	config[0].movement_type = BulletConfig.MoveFunction.LINEAR
	config[0].direction = (_target - position).normalized()
	config[0].direction.y = 0
	
	if (config[0].direction == Vector3.ZERO): return
	
	Bullet_Factory.line_formation(self, Vector3.ZERO, config[0].direction * 2, 3, config)
	
	shoot()
