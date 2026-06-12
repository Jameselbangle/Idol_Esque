extends Node3D

var slime := preload("res://prefabs/enemies/slime.tscn")
var mandrake := preload("res://prefabs/enemies/mandrake.tscn")

@export var switch : bool = false
@export var enemies_node : Node
@export var players_node : Node
var no_shield : bool = false

var time : float = 5

func _process(delta: float) -> void:
	time -= delta
	
	if Input.is_action_just_pressed("ShieldsOff"):
		no_shield = !no_shield
		print(no_shield)
	
	if time <= 0:
		var instance
		var random_bool: bool = randi() % 2 == 0
		if random_bool:
			instance = slime.instantiate()
		else:
			instance = mandrake.instantiate()
		var rng = RandomNumberGenerator.new()
		
		if not no_shield:
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
		else:
			instance.set_shield(BulletConfig.BulletColour.ENEMY)

		instance.global_transform = global_transform
		enemies_node.add_child(instance)
		time = 8

func _unhandled_input(event: InputEvent) -> void:
	var instance
	
	if event.is_action_pressed("spawn_1"):
		instance = slime.instantiate()
	
	if event.is_action_pressed("spawn_2"):
		instance = slime.instantiate() if switch else mandrake.instantiate()
	
	if event.is_action_pressed("kill_all"):
		for e in enemies_node.get_children():
			e.damage(999)
		
		for b in get_node("/root/PlayArtTest/bullet_manager").get_children():
			b.explode()
	
	if event.is_action_pressed("revive_all"):
		for p in players_node.get_children():
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

		instance.global_transform = global_transform
		enemies_node.add_child(instance)
		#instance.global_transform = global_transform
