extends Node3D

var slime := preload("res://prefabs/enemies/slime.tscn")
var mandrake := preload("res://prefabs/enemies/mandrake.tscn")

var switch : bool = false
var hasPressed : bool = false

func _process(delta: float) -> void:
	var pressing := Input.is_key_pressed(KEY_1) or Input.is_key_pressed(KEY_2)

	if pressing and not hasPressed:
		hasPressed = true

		var instance

		if Input.is_key_pressed(KEY_1):
			instance = mandrake.instantiate() if switch else slime.instantiate()

		elif Input.is_key_pressed(KEY_2):
			instance = slime.instantiate() if switch else mandrake.instantiate()

		add_child(instance)

	elif not pressing:
		hasPressed = false
