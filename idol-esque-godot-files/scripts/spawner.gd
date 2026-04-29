extends Node3D

var slime := preload("res://prefabs/enemies/slime.tscn")
var mandrake := preload("res://prefabs/enemies/mandrake.tscn")

@export var switch : bool = false


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
		var rng = RandomNumberGenerator.new()
		match rng.randi_range(1, 6):
			1:
				instance.set_shield(BulletConfig.BulletColour.RED)
			2:
				instance.set_shield(BulletConfig.BulletColour.BLUE)
			3:
				instance.set_shield(BulletConfig.BulletColour.YELLOW)
			4:
				pass
			5:
				pass
			6:
				pass
		var enemies_node = get_node("/root/PlaytestRoom/NavigationRegion3D/enemies")

		instance.global_transform = global_transform
		enemies_node.add_child(instance)
		#instance.global_transform = global_transform
