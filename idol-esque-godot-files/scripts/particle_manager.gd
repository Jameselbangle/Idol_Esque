extends Node

var Particles = {
	"mandrake" : preload("res://prefabs/particles/particle_mandrake.tscn"), ## Mandrake
	## New particles here...
}

func _ready() -> void:
	GlobalSignals.connect("create_particles", Callable(self, "create_particles"))

func create_particles(Pname, Pposition):
	
	print("creating particle...")
	
	var effect = null
	
	for p in Particles:
		if p in Pname:
			effect = Particles[p].instantiate()
			break
	
	## Null check
	if effect == null:
		print("Paticle Called Null: " + Pname)
		return
	
	
	
	effect.global_position = Pposition
	
	## Used for mandrakes to appear slick
	effect.rotation.x += 70
	
	add_child(effect)
