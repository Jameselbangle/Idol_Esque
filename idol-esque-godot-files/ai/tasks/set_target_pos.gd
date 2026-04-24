@tool
extends BTAction

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
	var target : Vector3 = enemy.choose_target_position()
	enemy.set_movement_target(target)
	return SUCCESS
