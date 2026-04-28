extends Node3D

var slime := preload("res://prefabs/enemies/slime.tscn")
var mandrake := preload("res://prefabs/enemies/mandrake.tscn")

var switch : bool = false


func _unhandled_input(event: InputEvent) -> void:
	var instance
	
	if event.is_action_pressed("spawn_1"):
		instance = mandrake.instantiate() if switch else slime.instantiate()
	
	if event.is_action_pressed("spawn_2"):
		instance = slime.instantiate() if switch else mandrake.instantiate()
	
	if event.is_action_pressed("kill_all"):
		for e in get_node("/root/PlaytestRoom/NavigationRegion3D/enemies").get_children():
			e.damage(999)
	
	if event.is_action_pressed("revive_all"):
		for p in get_node("/root/PlaytestRoom/players").get_children():
			p.revive()
	
	if instance != null:
		add_child(instance)
