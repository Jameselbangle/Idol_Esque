class_name Bullet_Factory extends Node

static func single_formation(source : Enemy, offset : Vector3, bullet_config : BulletConfig, rotation : float = 0):
	var spawn_pos : Vector3 = source.position + offset
	var bullet = source.enemy_bullet_scene.instantiate()
	bullet.setup(bullet_config, spawn_pos)
	bullet.transform = bullet.transform.rotated(Vector3.UP, rotation)
	source.bullet_buffer.append(bullet)

static func line_formation(source : Enemy, start_position : Vector3, end_position : 
						Vector3, bullet_count : int, bullet_config : BulletConfig, rotation : float = 0) -> void:
	assert(bullet_count > 1, "Needs at least 2 bullets to form a line")
	var step_size : float = 1.0 / (bullet_count - 1)
	var t : float = 0

	while t <= 1:
		var spawn_pos : Vector3 = source.position + start_position.lerp(end_position, t)
		var bullet = source.enemy_bullet_scene.instantiate()
		bullet.setup(bullet_config, spawn_pos)
		bullet.transform = bullet.transform.rotated(Vector3.UP, rotation)
		source.bullet_buffer.append(bullet)
		t += step_size

static func circle_formation(source : Enemy, offset : Vector3, radius : float, 
						bullet_count : int, bullet_config : BulletConfig, rotation : float = 0):
	assert(radius > 0, "Radius needs to be larger than 0")
	var step_size : float = 2 * PI / bullet_count
	var theta : float = 0
	
	while theta < TAU:
		var x_pos = cos(theta) * radius
		var z_pos : float = 0.0
		if theta < PI:
			z_pos = sqrt(radius ** 2 - (x_pos - offset.x) ** 2) + offset.z
		else:
			z_pos = -sqrt(radius ** 2 - (x_pos - offset.x) ** 2) + offset.z
		
		var spawn_pos : Vector3 = source.position + offset
		spawn_pos.x += x_pos 
		spawn_pos.z += z_pos
		
		var bullet = source.enemy_bullet_scene.instantiate()
		bullet.setup(bullet_config, spawn_pos)
		bullet.transform = bullet.transform.rotated(Vector3.UP, rotation)
		source.bullet_buffer.append(bullet)
		theta += step_size

static func polygon_formation(source : Enemy, offset : Vector3, radius : float, sides : int,
						bullet_per_side : int, bullet_config : BulletConfig, rotation : float = 0):
	assert(radius > 0, "Radius needs to be larger than 0")
	assert(sides > 2, "Sides needs to be larger than 2")
	
	var theta : float = TAU / sides
	
	for i in range(1, sides + 1):
		var start : Vector3 = Vector3(cos(theta * (i - 1)), 0, sin(theta * (i - 1))) + offset
		start *= radius
		var end : Vector3 = Vector3(cos(theta * i), 0, sin(theta * i)) + offset
		end *= radius
		line_formation(source, start, end, bullet_per_side, bullet_config, rotation)
		source.bullet_buffer.pop_back()

static func arc_formation(source : Enemy, offset : Vector3, radius : float, 
						bullet_count : int, bullet_config : BulletConfig, rotation : float = 0):
	assert(radius > 0, "Radius needs to be larger than 0")
	var step_size : float = 2 * PI / bullet_count
	var theta : float = 0
	
	while theta < PI:
		var x_pos = cos(theta) * radius
		var z_pos : float = 0.0
		if theta < PI:
			z_pos = sqrt(radius ** 2 - (x_pos - offset.x) ** 2) + offset.z
		else:
			z_pos = -sqrt(radius ** 2 - (x_pos - offset.x) ** 2) + offset.z
		
		var spawn_pos : Vector3 = source.position + offset
		spawn_pos.x += x_pos 
		spawn_pos.z += z_pos
		
		var bullet = source.enemy_bullet_scene.instantiate()
		bullet.setup(bullet_config, spawn_pos)
		bullet.transform = bullet.transform.rotated(Vector3.UP, rotation)
		source.bullet_buffer.append(bullet)
		theta += step_size
