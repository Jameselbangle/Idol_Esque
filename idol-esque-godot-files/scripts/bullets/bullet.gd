class_name EnemyBullet extends CharacterBody3D

@export var config : Array[BulletConfig] = []

@onready var sprite: Sprite3D = $Sprite3D

var tick_step = 0

func setup(_config : Array[BulletConfig], _position : Vector3 = Vector3.ZERO) :
	config = _config
	position = _position + Vector3(0, config[0].size/2, 0)
	
	scale = Vector3(config[0].size, config[0].size, config[0].size)
	
	var collision_object : Area3D = $Area3D
	
	collision_object.collision_mask = 0
	
	match config[tick_step].bullet_colour:
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
	
	if (config[tick_step].tick_timer <= 0):
		tick()
		return
	else:
		config[tick_step].tick_timer -= delta

func _physics_process(_delta: float) -> void:
	if config.is_empty():
		return
	match config[tick_step].movement_type:
		BulletConfig.MoveFunction.LINEAR:
			velocity = config[tick_step].direction * config[tick_step].speed
		BulletConfig.MoveFunction.QUADRATIC:
			velocity = config[tick_step].direction * config[tick_step].speed
			velocity += config[tick_step].acc * _delta
			config[tick_step].direction = velocity / config[tick_step].speed
		BulletConfig.MoveFunction.HOMING:
			var direction = config[tick_step].target - position
			direction = direction.normalized()
			velocity += direction * config[tick_step].speed
		BulletConfig.MoveFunction.WAVE:
			push_error("Function not implemented")
		BulletConfig.MoveFunction.TARGET:
			var dir = config[tick_step].target - position
			dir = dir.normalized()
			config[tick_step].direction = dir
			velocity = dir * config[tick_step].speed
	
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Enemy:
		body.damage(config[0].damage, config[tick_step])
	queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	print("area UNHANDLED " + area.name)

func tick() -> void:
	tick_step += 1
	if (config.size() <= tick_step):
		queue_free()
		return
