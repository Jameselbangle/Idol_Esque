extends Node3D

@onready var _animated_sprite = $AnimatedSprite3D

func _process(_delta):
	_animated_sprite.play("default")
