@tool
extends BTAction

# Task parameters.
@export var target_pos: Vector3
var enemy : Enemy


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "SetTargetPos"


# Called to initialize the task.
func _setup() -> void:
	enemy = scene_root


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if not is_instance_valid(enemy):
		return FAILURE
	var rng = RandomNumberGenerator.new()
	var pos_x = rand_with_min_mag(rng, 3.0, 10.0)
	var pos_z = rand_with_min_mag(rng, 3.0, 10.0)
	var target : Vector3 = enemy.global_position + Vector3(pos_x, 0, pos_z)
	enemy.set_movement_target(target)
	return SUCCESS


func rand_with_min_mag(rng: RandomNumberGenerator, min_mag: float, max_mag: float) -> float:
	if rng.randf() < 0.5:
		return rng.randf_range(-max_mag, -min_mag)
	else:
		return rng.randf_range(min_mag, max_mag)
