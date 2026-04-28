extends CharacterBody3D

@export_group("Player Info")
@export var player_count : int = 0
@export var player_colour : BulletConfig.BulletColour

@export_group("Speeds")
@export var move_speed : float = 7.0
@export var base_slipperyness_lerp : float = 7
var slipperyness_lerp : float = base_slipperyness_lerp

@export_group("Dash")
@export var dash_cooldown : float = 1.0
@export var dash_length_seconds : float = 0.3
@export var dash_speed : float = 30.0

@export_group("Rotation Angle")
## Denominator for the 
@export var denominator  : int = 5
var num : int = denominator  - 1

@export_group("Bullets")
@export var bullet_speed : float = 20.0
@export var charge_time_seconds : float = 0.8

@export_group("Timers")
@export var firerate : float = 0.2
@export var chargerate : float = firerate * 2

@export_group("Is Keyboard?")
@export var keyboard_mode : bool = false

@onready var player_sprite : Sprite3D = $player_spr
@onready var bullet_spawn : Marker3D = $neck/BulletSpawn
var bulletScene = preload("res://prefabs/bullet.tscn")
var sprites = {
	"front" : preload("res://art/characters/players/front.png"),
	"back" : preload("res://art/characters/players/back.png"),
	"left" : preload("res://art/characters/players/left.png"),
	"right" : preload("res://art/characters/players/right.png")
}

@onready var fire_rate_timer : Timer = $FireRate
@onready var charge_rate_timer : Timer = $ChargeRate
@onready var dash_cooldown_timer : Timer = $DashCooldown
@onready var dash_length_timer : Timer = $DashLength

@onready var bar_charging : ProgressBar3D = $ChargeProgressBar
@onready var bar_dash_cooldown : ProgressBar3D = $DashProgressBar

@onready var neck : Node3D = $neck
@onready var character_body = get_node(".")

var joy_move : Vector2
var joy_look : Vector2

var is_shooting: bool = false
var is_charging: bool = false
var is_dashing: bool = false
var can_dash : bool = true

## rotating character with joystick
var deadzone: float = 0.3
var rotation_speed: float = 5.0
var target_angle: float

var mouse_captured : bool = false


func _ready() -> void:
	add_to_group("player")
	
	## Set initial wait times for Progress Bar
	charge_rate_timer.wait_time = charge_time_seconds
	bar_charging.max_value = charge_time_seconds
	
	## Set wait times for timers
	dash_cooldown_timer.wait_time = dash_cooldown
	bar_dash_cooldown.max_value = dash_cooldown
	dash_length_timer.wait_time = dash_length_seconds
	
	## TEMP Colour for sprites
	match player_colour:
		BulletConfig.BulletColour.RED:
			sprites["front"] = load("res://art/characters/players/Stella/Stella_front.png")
			sprites["back"] = load("res://art/characters/players/Stella/Stella_Back.png")
			sprites["left"] = load("res://art/characters/players/Stella/Stella_Left.png")
			sprites["right"] = load("res://art/characters/players/Stella/Stella_Right.png")
		BulletConfig.BulletColour.BLUE:
			sprites["front"] = load("res://art/characters/players/Iris/Iris_Front.png")
			sprites["back"] = load("res://art/characters/players/Iris/Iris_Back.png")
			sprites["left"] = load("res://art/characters/players/Iris/Iris_Left.png")
			sprites["right"] = load("res://art/characters/players/Iris/Iris_Right.png")
		BulletConfig.BulletColour.YELLOW:
			sprites["front"] = load("res://art/characters/players/Bee/Bee_Front.png")
			sprites["back"] = load("res://art/characters/players/Bee/Bee_Back.png")
			sprites["left"] = load("res://art/characters/players/Bee/Bee_Left.png")
			sprites["right"] = load("res://art/characters/players/Bee/Bee_Right.png")


func _unhandled_input(event: InputEvent) -> void:
	## Universal inputs
	## Mouse capturing
	if event.is_action("capture"):
		capture_mouse()
	if event.is_action("escape"):
		release_mouse()
	
	## -------------------------------- 
	## KEYBOARD MODE
	if keyboard_mode:
		## KEY LOOK
		match player_count:
			0:
				if event.is_action_pressed("left_look_1"):
					KEY_rotate(-1)
				if event.is_action_pressed("right_look_1"):
					KEY_rotate(1)
			1:
				if event.is_action_pressed("left_look_2"):
					KEY_rotate(-1)
				if event.is_action_pressed("right_look_2"):
					KEY_rotate(1)
			2:
				if event.is_action_pressed("left_look_3"):
					KEY_rotate(-1)
				if event.is_action_pressed("right_look_3"):
					KEY_rotate(1)
		
		## KEY FIRE
		if (event.is_action_pressed("fire_1") and player_count == 0) or (event.is_action_pressed("fire_2") and player_count == 1) or (event.is_action_pressed("fire_3") and player_count == 2):
			if fire_rate_timer.time_left == 0:
				shoot()
			is_shooting = true
		if (event.is_action_released("fire_1") and player_count == 0) or (event.is_action_released("fire_2") and player_count == 1) or (event.is_action_released("fire_3") and player_count == 2):
			is_shooting = false
		
		## Dash
		if (can_dash and event.is_action_pressed("dash_1") and player_count == 0):# or (event.is_action_pressed("dash_2") and player_count == 1) or (event.is_action_pressed("dash_3") and player_count == 2):
			dash()
		
		## Charge
		if !is_charging and (event.is_action_pressed("charge_1") and player_count == 0):# or (event.is_action_pressed("dash_2") and player_count == 1) or (event.is_action_pressed("dash_3") and player_count == 2):
			charge_shot_charge()
		elif is_charging and (event.is_action_released("charge_1") and player_count == 0):# or (event.is_action_pressed("dash_2") and player_count == 1) or (event.is_action_pressed("dash_3") and player_count == 2):
			charge_shot_fire()
	## -------------------------------- 
	
	## Sort for individual players
	if event.device != player_count:
		return
	
	## Handles firing bullets seperate from PhysicsProcess 
	if event.is_action_pressed("fire") and event.device == player_count and !is_shooting and !is_charging:
		if fire_rate_timer.is_stopped():
			shoot()
		is_shooting = true
	elif event.is_action_released("fire") and event.device == player_count and is_shooting:
		is_shooting = false
	
	## Charge fire attack
	if event.is_action_pressed("charge_fire") and event.device == player_count and !is_charging:
		charge_shot_charge()
	elif event.is_action_released("charge_fire") and event.device == player_count and is_charging:
		charge_shot_fire()
	
	## Dash
	if event.is_action_pressed("dash") and event.device == player_count and can_dash:
		dash()
		bar_dash_cooldown.visible = true
	
	## Movement
	#if (event.is_action("left") or event.is_action("right") or event.is_action("up") or event.is_action("down")) and event.device == player_count:
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


## TODO: Move input and moving code to _unhandled input
func _physics_process(delta: float) -> void:
	## Apply gravity to velocity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	### --------------
	### TEMP MOVEMENT
	
	if keyboard_mode:
		if player_count == 0:
			joy_move = Input.get_vector("left1","right1","up1","down1").normalized()
		elif player_count == 1:
			joy_move = Input.get_vector("left2","right2","up2","down2").normalized()
		elif player_count == 2:
			joy_move = Input.get_vector("left3","right3","up3","down3").normalized()
	
	### --------------
	
	## progress bar checker
	if !charge_rate_timer.is_stopped():
		bar_charging.value = bar_charging.max_value - charge_rate_timer.time_left
	if !dash_cooldown_timer.is_stopped():
		bar_dash_cooldown.value = bar_dash_cooldown.max_value - dash_cooldown_timer.time_left
	
	## Deadzone checker & apply velocity
	var movement_vector = sqrt(joy_move.x **2 + joy_move.y **2)
	if abs(movement_vector) < deadzone:
		joy_move = Vector2.ZERO
	
	velocity.x = lerp( velocity.x, joy_move.x * move_speed, slipperyness_lerp * delta) 
	velocity.z = lerp( velocity.z, joy_move.y * move_speed, slipperyness_lerp * delta) 
	
	## Rotation code
	## source: https://www.youtube.com/watch?v=1C2AAiNxoc8

	if joy_look.length() >= deadzone:
		target_angle = -joy_look.angle() + deg_to_rad(90.0)
	if neck.rotation.y != target_angle:
		var rotation_lerp_weight: float = 1.0 - exp(-rotation_speed * delta)
		neck.rotation.y = lerp_angle(neck.rotation.y, target_angle, rotation_lerp_weight)
	
	## Sprite rotation code
	if neck.rotation.y > (num * PI/denominator ) or neck.rotation.y < -(num * PI/denominator ):
		player_sprite.texture = sprites["back"]
	elif neck.rotation.y > (PI/denominator ):
		player_sprite.texture = sprites["right"]
	elif neck.rotation.y < -(PI/denominator ):
		player_sprite.texture = sprites["left"]
	else:
		player_sprite.texture = sprites["front"]
	## Fixes if it goes over or under values
	if neck.rotation.y > (PI):
		neck.rotation.y -= 2 * PI
	if neck.rotation.y < -(PI):
		neck.rotation.y += 2 * PI
	
	## Dash speed code
	if is_dashing:
		## Linear decrease in speed
		var time_progressed_ratio = (1 / dash_length_timer.wait_time) * (dash_length_timer.wait_time - dash_length_timer.time_left)
		var diff = time_progressed_ratio * (dash_speed - move_speed)
		
		## Exponentional INC in speed
		#var time_left_ratio = 1 - ((1 / dash_length_timer.wait_time) * (dash_length_timer.wait_time - dash_length_timer.time_left))
		#var diff = ((1/(time_left_ratio + 0.9)**2)-0.24) * (dash_speed - move_speed)
		
		var temp_speed = dash_speed - diff
		velocity = velocity.normalized() * temp_speed
	
	## Use velocity to actually move
	move_and_slide()


func KEY_rotate(rot: float):
	target_angle = neck.rotation.y + (rot * (PI / 2))
	neck.rotation.y = target_angle

## Creating Bullets and firing
func shoot():
	fire_rate_timer.start()
	fire_rate_timer.start(firerate)
	
	var spawn_pos = bullet_spawn.global_position
	var direction := Vector3(sin(neck.rotation.y), 0, cos(neck.rotation.y))
	
	var config : Array[BulletConfig] = [BulletConfig.new()]
	config[0].direction = direction
	config[0].bullet_colour = player_colour
	config[0].speed = bullet_speed
	
	var bullet = bulletScene.instantiate()
	bullet.setup(config, spawn_pos)
	get_tree().current_scene.get_node("bullet_manager").add_child(bullet)

func _on_fire_rate_timeout() -> void:
	if is_shooting and !is_charging:
		shoot()


func charge_shot_charge():
	charge_rate_timer.start()
	is_charging = true
	bar_charging.visible = true

func charge_shot_fire():
	## Allows for a 1/5 allowance (e.g. since charge time is 1s, if its been .9s you can shoot anyway)
	if charge_rate_timer.time_left <= (0.2) * charge_time_seconds:
		charge_shoot()
	is_charging = false
	bar_charging.visible = false
	if fire_rate_timer.is_stopped():
		fire_rate_timer.start()

func charge_shoot():
	var spawn_pos = bullet_spawn.global_position
	var speed : float = 10.0
	
	var direction := Vector3(sin(neck.rotation.y), 0, cos(neck.rotation.y))
	
	var config : Array[BulletConfig] = [BulletConfig.new()]
	config[0].direction = direction
	config[0].speed = speed
	config[0].bullet_colour = player_colour
	config[0].size = 2.0
	config[0].damage = 5.0
	
	var bullet = bulletScene.instantiate()
	bullet.setup(config, spawn_pos)
	get_tree().current_scene.get_node("bullet_manager").add_child(bullet)


## Dash begin
func dash():
	bar_dash_cooldown.visible = true
	
	## Makes dash Unable & starts timers
	can_dash = false
	is_dashing = true
	dash_cooldown_timer.start()
	dash_length_timer.start()
	
	character_body.set_collision_layer_value(2, false)
	
	## Dash Movement enabled
	#velocity = velocity.normalized() * dash_speed
	slipperyness_lerp = 0

## Dash Movement disabled
func _on_dash_length_timeout() -> void:
	is_dashing = false
	slipperyness_lerp = base_slipperyness_lerp
	character_body.set_collision_layer_value(2, true)
	
	## Enable/disable for precise stopping/starting
	#velocity = velocity / dash_speed 

## Re-enables dash 
func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	bar_dash_cooldown.visible = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
