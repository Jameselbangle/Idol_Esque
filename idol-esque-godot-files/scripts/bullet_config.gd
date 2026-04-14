class_name BulletConfig extends Resource

enum MoveFunction {LINEAR, QUADRATIC, HOMING, WAVE}
enum BulletColour {ENEMY, RED, YELLOW, BLUE}

@export var speed : float = 1.0
@export var direction : Vector3
@export var movement_type : MoveFunction = MoveFunction.LINEAR 
@export var bullet_colour : BulletColour = BulletColour.ENEMY
