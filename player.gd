extends Area2D
@export var speed = 200
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect()

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		
	if velocity.x != 0:
		$PlayerSprite.animation = "Walking"
		$PlayerSprite.flip_v = false
		$PlayerSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$PlayerSprite.animation = "Walking"
		$PlayerSprite.flip_v = velocity.y < 0
			
