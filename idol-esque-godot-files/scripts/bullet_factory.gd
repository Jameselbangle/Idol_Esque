class_name Bullet_Factory extends Node
static func line_formation(source : Enemy, start_position : Vector3, end_position : 
						Vector3, bullet_count : int, bullet_config : BulletConfig) -> void:
	assert(bullet_count > 1, "Needs at least 2 bullets to form a line")
	var step_size : float = 1.0 / (bullet_count - 1)
	var t : float = 0

	while t <= 1:
		var spawn_pos : Vector3 = source.position + start_position.lerp(end_position, t)
		var bullet = source.enemy_bullet_scene.instantiate()
		bullet.setup(bullet_config, spawn_pos)
		source.bullet_buffer.append(bullet)
		t += step_size


static func circle_formation(source : Enemy, offset : Vector3, radius : float, 
						bullet_count : int, bullet_config : BulletConfig):
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
		source.bullet_buffer.append(bullet)
		theta += step_size

static func arc_formation():
	push_error("Function not implemented")
	
