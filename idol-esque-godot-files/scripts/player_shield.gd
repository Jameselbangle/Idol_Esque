extends Area3D

@export var health = 10

func setup(s_count : int = 0, s_pos : Vector3 = Vector3.ZERO, s_health : int = health):
	position = s_pos
	health = s_health
	name = 'player_shield_' + str(s_count)

func damage(hit : int, _bullet_config : BulletConfig = null):
	
	health -= hit
	
	if health <= 0:
		break_shield()

func break_shield():
	GlobalSignals.emit_signal("create_particles", "mandrake", global_position)
	queue_free()
