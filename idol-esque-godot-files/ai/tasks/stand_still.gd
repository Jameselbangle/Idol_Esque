@tool
extends BTAction

var enemy : Enemy

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "StandStill"

# Called to initialize the task.
func _setup() -> void:
	enemy = scene_root

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if not is_instance_valid(enemy):
		return FAILURE
	enemy.set_movement_target(enemy.position)
	return SUCCESS
