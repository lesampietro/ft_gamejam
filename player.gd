extends CharacterBody2D
@export var speed = 500
@export var max_health = 10
var screen_size: Vector2 # o tipo do retorno do screen size. x, y
@onready var col_shape = $CollisionShape2D
@onready var health_bars = [$PlayerGUI/Control/HealthBar/ProgressBar, $PlayerGUI/HealthBar2/ProgressBar]
@onready var gameoverlayer = $"../GameOverLayer"
@onready var winLayer = $"../WinLayer"
@onready var scoreLabel = $PlayerGUI/Control/ScoreLabel
@onready var moveSoundEffect = $MoveSoundEffect

var dominated_victims = []
var trail_positions: Array = []
@onready var pink_victim = get_node("../PinkVictim")

enum PlayerState { NORMAL, ATTACK }
var state = PlayerState.NORMAL

var pause_timer = 0.0
var health = 10
var win_condition = 10

#knockback
var knockback_velocity = Vector2.ZERO
var knockback_decay = 800

func start(pos):

	position = pos
	show()
	$CollisionShape2D.disabled = false

func _ready() -> void:
	add_to_group("player")
	position = Vector2(-1225, 310)
	screen_size = get_viewport_rect().size # add size pq retorna o tamanho da tela
	$PlayerSprite.visible = false # player invisível no início
	$SpawnSprite.visible = true
	$SpawnSprite.play("effect")
	$SpawnSprite.animation_finished.connect(_on_spawn_sprite_animation_finished)
	$PlayerSprite.play()
	update_health_bars()
	print(winLayer.visible)

func update_health_bars() -> void:
	health_bars[0].value = health
	health_bars[1].value = health


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

func initSoundMoving() -> void:
	if (!moveSoundEffect.playing):
		moveSoundEffect.play()
		
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
				initSoundMoving()
			elif movement.x < 0:
				movementState = "move_left"
				initSoundMoving()
			elif movement.y > 0:
				movementState = "move_down"
				initSoundMoving()
			elif movement.y < 0:
				movementState = "move_up"
				initSoundMoving()
			else:
				movementState = "Idle"
				moveSoundEffect.stop()
		PlayerState.ATTACK:
			moveSoundEffect.stop()
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

func playerActions(delta: float) -> void:
	if knockback_velocity.length() > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		move_and_slide()
	else:
		playerMove(delta)

func add_dominated(victim): # adiciona vitimas a array
	if dominated_victims.size() == 0:
		victim.follow_target = self # se array estiver vazio, segue player
	else:
		victim.follow_target = dominated_victims[-1] # se tiver vitimas, segue a ultima
	dominated_victims.append(victim) # adiciona a ultima posição da array

	scoreLabel.text = "Score: " + str(dominated_victims.size())
	if (dominated_victims.size() >= win_condition):
		print("you win")
		winLayer.visible = true

func is_end_game() -> bool:
	if (health == 0):
		gameoverlayer.visible = true
		return true
	if (dominated_victims.size() >= win_condition):
		winLayer.visible = true
		return true
	return false

func _physics_process(delta: float) -> void:
	if (is_end_game()):
		return
	if pause_timer > 0:
		pause_timer -= delta
	else:
		if state == PlayerState.ATTACK:
			state = PlayerState.NORMAL

	playerActions(delta)


func take_damage(damage_amount: int):
	health -= damage_amount
	health = max(health, 0)
	update_health_bars()
	print("Player tomou dano!")


func _on_spawn_sprite_animation_finished() -> void:
	$SpawnSprite.visible = false
	$PlayerSprite.visible = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.begins_with("PinkVictim") and state == PlayerState.NORMAL:
		state = PlayerState.ATTACK
		#$PlayerSprite.animation = "attack_down" # ou outro dependendo da direção
		#$PlayerSprite.play()
		pause_timer = 1.0
		


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name.begins_with("PinkVictim") and state == PlayerState.ATTACK:
		state = PlayerState.ATTACK


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://player.tscn")
