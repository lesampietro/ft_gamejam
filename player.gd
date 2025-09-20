extends Area2D
@export var speed = 200
var screen_size

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
	
func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	#hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func _ready() -> void:
	screen_size = get_viewport_rect()
	$PlayerSprite.play()
	
	
func check_keyboard_actions() -> Vector2:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	return velocity

func playerMove(delta: float) -> void: 
	var movement = check_keyboard_actions()
	var movementState = "Idle" # Começa como Idle

	if movement.x != 0:
		if movement.x > 0:
			movementState = "move_right"
		else:
			movementState = "move_left"
	elif movement.y != 0:
		movementState = "move_down"
	elif movement.length() > 0:
		movementState = "default"

	# Só troca se for diferente!
	if $PlayerSprite.animation != movementState:
		$PlayerSprite.animation = movementState
		$PlayerSprite.play()

	if movement.length() > 0:
		position += movement.normalized() * speed * delta

func playerActions(delta: float) -> void:
	playerMove(delta)
	


func _process(delta: float) -> void:
	playerActions(delta)
	
