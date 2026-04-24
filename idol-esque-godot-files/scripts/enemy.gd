@abstract class_name Enemy extends CharacterBody3D

@export var _movement_speed: float = 4.0
@export var _health : int = 5

@export var _bullet_scene: PackedScene

@onready var _bullet_spawn : Marker3D = $BulletSpawn
@onready var _navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export var _shield : BulletConfig.BulletColour

var _bullet_buffer = []

@abstract func choose_target() -> Vector3

#TODO: Should be made ABSTRACT
func _physics_process(_delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(_navigation_agent.get_navigation_map()) == 0:
		return
	if _navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = _navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * _movement_speed
	if _navigation_agent.avoidance_enabled:
		_navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

#TODO: Should be made ABSTRACT
func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

#TODO: Should be made ABSTRACT
func set_movement_target(movement_target: Vector3) -> void:
	_navigation_agent.set_target_position(movement_target)

#TODO: Should be made ABSTRACT
func shoot() -> void:
	var bullet_manager : Node = get_tree().current_scene.get_node("BulletManager")
	for bullet in _bullet_buffer:
		bullet_manager.add_child(bullet)
	_bullet_buffer.clear()

#TODO: Should be made ABSTRACT
func set_shield(col : BulletConfig.BulletColour):
	_shield = col
	match col:
		BulletConfig.BulletColour.RED:
			$Sprite3D.modulate = Color.RED
		BulletConfig.BulletColour.YELLOW:
			$Sprite3D.modulate = Color.YELLOW
		BulletConfig.BulletColour.BLUE:
			$Sprite3D.modulate = Color.BLUE
		BulletConfig.BulletColour.ENEMY:
			$Sprite3D.modulate = Color.WHITE

#TODO: Should be made ABSTRACT
func remove_shield():
	_shield = BulletConfig.BulletColour.ENEMY
	$Sprite3D.modulate = Color.WHITE

#TODO: Should be made ABSTRACT
func damage(hit : int, bullet_config : BulletConfig = null):
	if _shield != BulletConfig.BulletColour.ENEMY:
		if _shield == bullet_config.bullet_colour:
			remove_shield()
		return
	
	_health -= hit
