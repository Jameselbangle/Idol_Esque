extends CharacterBody3D

@export_group("Player Info")
@export var player_count : int = 0
@export var player_colour : BulletConfig.BulletColour

@export_group("Speeds")
@export var move_speed : float = 7.0
@export var slipperyness_lerp : int = 7

@export_group("Rotation Angle")
@export var den : int = 5
var num : int = den - 1


@onready var player_sprite : Sprite3D = $player_spr
@onready var bullet_spawn : Marker3D = $BulletSpawn
var bulletScene = preload("res://scenes/bullet.tscn")
var sprites = {
	"front" : preload("res://sprites/Player/front.png"),
	"back" : preload("res://sprites/Player/back.png"),
	"left" : preload("res://sprites/Player/left.png"),
	"right" : preload("res://sprites/Player/right.png")
}


var joy_move : Vector2
var joy_look : Vector2

var is_shooting: bool = false

## Look around rotation speed. mouse
var look_speed : float = 0.002

## rotating character with joystick
var deadzone: float = 0.5
var rotation_speed: float = 5.0
var target_angle: float

var mouse_captured : bool = false
var look_rotation : Vector2



func _ready() -> void:
	add_to_group("player")
	look_rotation.y = rotation.y
	
	## TEMP Colour for sprites
	match player_colour:
		BulletConfig.BulletColour.RED:
			player_sprite.modulate = Color.RED
		BulletConfig.BulletColour.BLUE:
			player_sprite.modulate = Color.BLUE
		BulletConfig.BulletColour.YELLOW:
			player_sprite.modulate = Color.YELLOW


func _unhandled_input(event: InputEvent) -> void:
	## Universal inputs
	## Mouse capturing
	if event.is_action("capture"):
		capture_mouse()
	if event.is_action("escape"):
		release_mouse()
	
	## Sort for individual players
	if event.device != player_count:
		return
	
	## Handles firing bullets seperate from PhysicsProcess
	if event.is_action_pressed("fire") and event.device == player_count:
		if $FireRate.time_left == 0:
			shoot()
		is_shooting = true
	if event.is_action_released("fire") and event.device == player_count:
		is_shooting = false
	
	## movement
	#joy_move = Input.get_vector("left","right","up","down")
	joy_move = Vector2(
		Input.get_joy_axis(player_count, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(player_count, JOY_AXIS_LEFT_Y)
	)
	
	## rotation
	#joy_look = Input.get_vector("left_look","right_look","up_look","down_look")
	joy_look = Vector2(
		Input.get_joy_axis(player_count, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(player_count, JOY_AXIS_RIGHT_Y)
	)
	
	## Look around w/ mouse 
	#if mouse_captured and event is InputEventMouseMotion:
		#rotate_look(event.relative)

## TODO: Move input and moving code to _unhandled input
func _physics_process(delta: float) -> void:
	## Apply gravity to velocity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = lerp( velocity.x, joy_move.x * move_speed, slipperyness_lerp * delta) 
	velocity.z = lerp( velocity.z, joy_move.y * move_speed, slipperyness_lerp * delta) 
	
	### --------------
	### TEMP MOVEMENT
	var key_move: Vector2
	if player_count == 0:
		joy_move = Input.get_vector("left1","right1","up1","down1").normalized()
	elif player_count == 1:
		joy_move = Input.get_vector("left2","right2","up2","down2").normalized()
	elif player_count == 2:
		joy_move = Input.get_vector("left3","right3","up3","down3").normalized()
	
	if key_move != Vector2(0,0):
		velocity.x = lerp( velocity.x, key_move.x * move_speed, slipperyness_lerp * delta) 
		velocity.z = lerp( velocity.z, key_move.y * move_speed, slipperyness_lerp * delta) 
	
	### --------------
	
	## Rotation code
	## source: https://www.youtube.com/watch?v=1C2AAiNxoc8

	if joy_look.length() >= deadzone:
		target_angle = -joy_look.angle() + deg_to_rad(90.0)
	if rotation.y != target_angle:
		var rotation_lerp_weight: float = 1.0 - exp(-rotation_speed * delta)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_lerp_weight)
	
	
	## sprite rotation code
	if rotation.y > (num * PI/den) or rotation.y < -(num * PI/den):
		player_sprite.texture = sprites["back"]
	elif rotation.y > (PI/den):
		player_sprite.texture = sprites["right"]
	elif rotation.y < -(PI/den):
		player_sprite.texture = sprites["left"]
	else:
		player_sprite.texture = sprites["front"]
	
	## Use velocity to actually move
	move_and_slide()


## OLD
## Rotate us to look around.
## For Mouse, only use if no controller is present
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)


## Creating Bullets and firing
func shoot():
	$FireRate.start(.2)
	
	var spawn_pos = bullet_spawn.global_position
	var speed : float = 5.0
	
	var direction := Vector3(sin(rotation.y), 0, cos(rotation.y))
	
	var config : BulletConfig = BulletConfig.new()
	config.direction = direction
	config.speed = speed
	config.bullet_colour = player_colour
	
	var bullet = bulletScene.instantiate()
	bullet.setup(config, spawn_pos)
	get_tree().current_scene.get_node("bullet_manager").add_child(bullet)


func _on_fire_rate_timeout() -> void:
	if is_shooting:
		shoot()


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
