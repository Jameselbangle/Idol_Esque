class_name Enemy extends CharacterBody3D

@export var movement_speed: float = 4.0
@export var enemy_bullet_scene: PackedScene

@export var _health : int = 5

@onready var bullet_spawn : Marker3D = $BulletSpawn
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export var shield : BulletConfig.BulletColour

var test : bool = true


var bullet_buffer = []

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	var rng = RandomNumberGenerator.new()
	match rng.randi_range(0, 5):
		0:
			shield = BulletConfig.BulletColour.ENEMY
		1:
			shield = BulletConfig.BulletColour.ENEMY
		2:
			shield = BulletConfig.BulletColour.ENEMY
		3:
			shield = BulletConfig.BulletColour.YELLOW
			$Sprite3D.modulate = Color.YELLOW
		4:
			shield = BulletConfig.BulletColour.BLUE
			$Sprite3D.modulate = Color.BLUE
		5:
			shield = BulletConfig.BulletColour.RED
			$Sprite3D.modulate = Color.RED
var config : Array[BulletConfig] = [BulletConfig.new()]

func _process(float) -> void:
	if _health <= 0:
		queue_free()
	
	if test:
		test = false
		
		#config[0].movement_type = BulletConfig.MoveFunction.HOMING
		#config[0].direction = Vector3.RIGHT
		#config[0].speed = 5
		#config[0].acc = Vector3.LEFT * 0.1
		#config[0].target = Vector3(0, 1, 0)
		config[0].tick_timer = 100000
		
		var con2 : BulletConfig = BulletConfig.new()
		con2.movement_type = BulletConfig.MoveFunction.LINEAR
		con2.direction = Vector3.LEFT
		con2.speed = 1
		con2.tick_timer = 120
		
		config.append(con2)
		
		print("TEST")
		#Bullet_Factory.line_formation(self, Vector3(-3, 0, 4), Vector3(3, 0, 4), 5, config)
		Bullet_Factory.circle_formation(self, Vector3.ZERO, 2, 8, config)
		Bullet_Factory.circle_formation(self, Vector3.ZERO, 3, 8, config, PI / 8)
		#Bullet_Factory.polygon_formation(self, Vector3(0, 0, 0), 3.2, 6, 5, config)
		#Bullet_Factory.arc_formation(self, Vector3(0, 0, -3), 2, 18, config)
		#Bullet_Factory.single_formation(self, Vector3(-4, 0, 0), config)
		
		shoot_bullet_buffer(PI)

func _physics_process(_delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()


func set_movement_target(movement_target: Vector3) -> void:
	navigation_agent.set_target_position(movement_target)

func choose_target() -> Vector3:
	var players = get_tree().get_nodes_in_group("Players")
	var closest_player : CharacterBody3D = null
	var closest_distance := INF

	for player in players:
		var distance = global_position.distance_to(player.global_position)
	
		if distance < closest_distance:
			closest_distance = distance
			closest_player = player
	
	if closest_player == null:
		return Vector3.ZERO
	return closest_player.global_position

## Shoot bullet pattern at a desired location
func shoot(target_pos : Vector3 = Vector3.ZERO) -> void:
	var spawn_pos = bullet_spawn.global_position
	var speed : float = 5.0

	var direction : Vector3	= target_pos - position
	direction.y = 0
	direction = direction.normalized()

	var config : BulletConfig = BulletConfig.new()
	config.direction = direction
	config.speed = speed

	var bullet = enemy_bullet_scene.instantiate()
	bullet.setup(config, spawn_pos)
	get_tree().current_scene.get_node("BulletManager").add_child(bullet)


func shoot_bullet_buffer(rotation : float = 0) -> void:
	var current_scene : Node = get_tree().current_scene
	for i in bullet_buffer:
			i.transform = i.transform.rotated(Vector3.UP, rotation)
	for bullet in bullet_buffer:
		current_scene.add_child(bullet)
	bullet_buffer.clear()
	

func remove_shield():
	shield = BulletConfig.BulletColour.ENEMY
	$Sprite3D.modulate = Color.WHITE

func damage(hit : int, bullet_config : BulletConfig = null):
	if shield != BulletConfig.BulletColour.ENEMY:
		if shield == bullet_config.bullet_colour:
			remove_shield()
		return
	
	_health -= hit
