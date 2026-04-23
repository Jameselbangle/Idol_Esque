class_name EnemyBullet extends CharacterBody3D

@export var config : Array[BulletConfig] = []

@onready var sprite: Sprite3D = $Sprite3D

func setup(_config : Array[BulletConfig], _position : Vector3 = Vector3.ZERO) :
	config = _config
	position = _position + Vector3(0, config[0].size/2, 0)
	
	scale = Vector3(config[0].size, config[0].size, config[0].size)
	
	var collision_object : Area3D = $Area3D
	
	collision_object.collision_mask = 0
	
	match config[0].bullet_colour:
		BulletConfig.BulletColour.RED:
			$Sprite3D.modulate = Color.RED
			collision_object.set_collision_mask_value(1, true)
			collision_object.set_collision_mask_value(3, true)
		BulletConfig.BulletColour.YELLOW:
			$Sprite3D.modulate = Color.YELLOW
			collision_object.set_collision_mask_value(1, true)
			collision_object.set_collision_mask_value(3, true)
		BulletConfig.BulletColour.BLUE:
			$Sprite3D.modulate = Color.BLUE
			collision_object.set_collision_mask_value(1, true)
			collision_object.set_collision_mask_value(3, true)
		BulletConfig.BulletColour.ENEMY:
			collision_object.set_collision_mask_value(1, true)
			collision_object.set_collision_mask_value(2, true)
	

func _process(delta: float) -> void:
	if config.is_empty():
		return
	
	if (config.size() > 0 && config[0].tick_timer <= 0):
		tick()
		return
	config[0].tick_timer -= delta

func _physics_process(_delta: float) -> void:
	if config.is_empty():
		return
	match config[0].movement_type:
		BulletConfig.MoveFunction.LINEAR:
			velocity = config[0].direction * config[0].speed
		BulletConfig.MoveFunction.QUADRATIC:
			velocity = config[0].direction * config[0].speed
			velocity += config[0].acc * _delta
			config[0].direction = velocity / config[0].speed
		BulletConfig.MoveFunction.HOMING:
			var direction = config[0].target - position
			direction = direction.normalized()
			velocity += direction * config[0].speed
		BulletConfig.MoveFunction.WAVE:
			push_error("Function not implemented") 
	
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Enemy:
		body.damage(1, config)
	queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	print("area UNHANDLED " + area.name)

func tick() -> void:
	config.pop_front()
	if (config.size() == 0):
		queue_free()
		return
