extends CharacterBody2D
@export var speed = 200
var screen_size: Vector2 # o tipo do retorno do screen size. x, y
var change_timer = 0.0
var change_interval = 0.5
var direction = Vector2.ZERO
@onready var col_shape = $CollisionShape2D
var repel_distance = 200  # distância que a vítima começa a fugir
@onready var player = get_node("../Player")

enum VictimState { FREE, DOMINATED }
var state = VictimState.FREE
var follow_target: Node2D = null 

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _ready() -> void:
	screen_size = get_viewport_rect().size # add size pq retorna o tamanho da tela
	$PinkVictimSprite.animation = "idle"
	$PinkVictimSprite.play()

func victimRandomMove(delta: float) -> void:
	var to_player = player.global_position - global_position  # direção para o player
	var distance = to_player.length()

	# lógica de repelir + movimento aleatório
	if distance < repel_distance and distance != 0:
		direction = -to_player.normalized()  # foge do player
	else:
		change_timer -= delta
		if change_timer <= 0:
			direction.x = randf_range(-1, 1)
			direction.y = randf_range(-1, 1)
			if direction.length() != 0:
				direction = direction.normalized()
			change_timer = change_interval

	# aplica movimento
	velocity = direction * speed
	move_and_slide()
	
	# limita a posição dentro da tela
	var victimSize = 50
	global_position.x = clamp(global_position.x, victimSize, screen_size.x - victimSize)
	global_position.y = clamp(global_position.y, victimSize, screen_size.y - victimSize)

func victimFollowMove(delta: float) -> void:
	if follow_target:
		var to_target = follow_target.global_position - global_position
		if to_target.length() != 0:
			var direction_to_target = to_target.normalized()
			var spacing = 60
			var desired_position = follow_target.global_position - direction_to_target * spacing
			var offset = desired_position - global_position

			# evita vibração
			if offset.length() > 5: # só se mexe se estiver a mais de 5px
				direction = offset.normalized()
				velocity = direction * speed
				move_and_slide()
			else:
				velocity = Vector2.ZERO
		else:
			velocity = Vector2.ZERO

func victimMove(delta: float) -> void:
	match state:
		VictimState.FREE:
			victimRandomMove(delta)
		VictimState.DOMINATED:
			victimFollowMove(delta)

func victimActions(delta: float) -> void:
	victimMove(delta)

func _physics_process(delta: float) -> void:
	victimActions(delta)
	
func _on_area_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player" and state == VictimState.FREE:
		state = VictimState.DOMINATED
		player.add_dominated(self)
		speed = 500

func _on_area_player_detection_body_exited(body: Node2D) -> void:
	pass
