extends CharacterBody2D
@export var speed = 500
var screen_size: Vector2 # o tipo do retorno do screen size. x, y
@onready var col_shape = $CollisionShape2D
var dominated_victims = []
var trail_positions: Array = []
@onready var pink_victim = get_node("../PinkVictim")

enum PlayerState { NORMAL, ATTACK }
var state = PlayerState.NORMAL

var pause_timer = 0.0

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _ready() -> void:
	add_to_group("player")
	screen_size = get_viewport_rect().size # add size pq retorna o tamanho da tela
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
	if movement.length() > 0:
		movement = movement.normalized()
	velocity = movement * speed
	move_and_slide()
	
	match state:
		PlayerState.NORMAL:
			if movement.x > 0:
				movementState = "move_right"
			elif movement.x < 0:
				movementState = "move_left"
			elif movement.y > 0:
				movementState = "move_down"
			elif movement.y < 0:
				movementState = "move_up"
			else:
				movementState = "Idle"
		PlayerState.ATTACK:
			if movement.x > 0:
				movementState = "attack_right"
			elif movement.x < 0:
				movementState = "attack_left"
			elif movement.y > 0:
				movementState = "attack_down"
			elif movement.y < 0:
				movementState = "move_up"
			else:
				movementState = "attack_down"

	# Só troca se for diferente!
	if $PlayerSprite.animation != movementState:
		$PlayerSprite.animation = movementState
		$PlayerSprite.play()
		
	#var playerSize = 50
	#global_position.x = clamp(global_position.x, 0, screen_size.x - playerSize)
	#global_position.y = clamp(global_position.y, 0, screen_size.y - playerSize)

func playerActions(delta: float) -> void:
	playerMove(delta)

func add_dominated(victim): # adiciona vitimas a array
	if dominated_victims.size() == 0:
		victim.follow_target = self # se array estiver vazio, segue player
	else:
		victim.follow_target = dominated_victims[-1] # se tiver vitimas, segue a ultima
	dominated_victims.append(victim) # adiciona à ultima posição da array
	
	print(dominated_victims.size())

func _physics_process(delta: float) -> void:
	if pause_timer > 0:
		pause_timer -= delta
	else:
		if state == PlayerState.ATTACK:
			state = PlayerState.NORMAL
	
	playerActions(delta)
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.begins_with("PinkVictim") and state == PlayerState.NORMAL:
		state = PlayerState.ATTACK
		#$PlayerSprite.animation = "attack_down" # ou outro dependendo da direção
		#$PlayerSprite.play()
		pause_timer = 1.0
		


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name.begins_with("PinkVictim") and state == PlayerState.ATTACK:
		state = PlayerState.ATTACK
