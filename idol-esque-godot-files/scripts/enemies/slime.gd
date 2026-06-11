extends Enemy

@export var enemy_spacing = 1.0

func choose_target() -> Vector3:
	#TODO: Consider caching targets
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
	var closest_target: Vector3 = choose_target()
	var distance = position.distance_to(closest_target)
	var current_target: Vector3 = position

	# move away / toward logic
	if distance < 2:
		var direction: Vector3 = (position - closest_target).normalized()
		current_target = position + direction * 4
	elif distance > 6:
		var direction: Vector3 = (position - closest_target).normalized()
		current_target = position - direction * 4
	else:
		current_target = position

	# keep it grounded (CRITICAL FIX)
	current_target.y = position.y

	# enemy spacing avoidance
	for e in get_tree().get_nodes_in_group("enemies"):
		if e == self:
			continue

		if current_target.distance_to(e._navigation_agent.target_position) < enemy_spacing:
			var dir = (current_target - position).normalized()
			var perp = Vector3(-dir.z, 0, dir.x) # proper XZ perpendicular

			current_target = current_target + perp * enemy_spacing
			current_target.y = position.y
			return current_target

	return current_target
	



func _ready() -> void:
	$AnimationPlayer.play("idle") #trial of animation for enemies
	patterns.append(burst_shot)

func _process(delta: float) -> void:
	return

func burst_shot(_target : Vector3):
	var config : Array[BulletConfig] = [BulletConfig.new()]
	
	config[0].speed = 2
	config[0].movement_type = BulletConfig.MoveFunction.LINEAR
	config[0].direction = (_target - position).normalized()
	config[0].direction.y = 0
	
	if (config[0].direction == Vector3.ZERO): return
	
	Bullet_Factory.line_formation(self, Vector3.ZERO, config[0].direction * 2, 3, config)
	
	shoot()
