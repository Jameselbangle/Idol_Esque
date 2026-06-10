extends Node3D

@onready var _animated_sprite = $AnimatedSprite3D

func _ready():
	_animated_sprite.play("default")
