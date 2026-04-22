class_name BulletConfig extends Resource

enum MoveFunction {LINEAR, QUADRATIC, HOMING, WAVE}
enum BulletColour {ENEMY, RED, YELLOW, BLUE}

@export var speed : float = 1.0
@export var direction : Vector3
@export var acc : Vector3
@export var target : Vector3
@export var movement_type : MoveFunction = MoveFunction.LINEAR 
@export var bullet_colour : BulletColour = BulletColour.ENEMY
@export var tick_timer : float = 60.0
@export var size : float = 1.0
