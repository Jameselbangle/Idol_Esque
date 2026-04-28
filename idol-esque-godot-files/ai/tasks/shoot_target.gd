@tool
extends BTAction

# Task parameters.
@export var attackIndex: int = 0

var enemy : Enemy

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "ShootTarget"

# Called to initialize the task.
func _setup() -> void:
	enemy = scene_root

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if not is_instance_valid(enemy):
		return FAILURE
	var target_pos : Vector3 = enemy.choose_target()
	enemy.patterns[attackIndex].call(target_pos)
	return SUCCESS
