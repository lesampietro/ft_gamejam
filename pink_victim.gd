extends CharacterBody2D
@export var speed = 450
var screen_size: Vector2 # o tipo do retorno do screen size. x, y
var change_timer = 0.0
var change_interval = 0.5
var direction = Vector2.ZERO
@onready var col_shape = $CollisionShape2D
var repel_distance = 100  # distância que a vítima começa a fugir
@onready var player = get_node("../Player")

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
	screen_size = get_viewport_rect().size # add size pq retorna o tamanho da tela
	print("LOG: screen_size: ", screen_size)
	$PinkVictimSprite.play()
	
func victimRandomMove(delta: float) -> void:
	var to_player = global_position - player.global_position
	var distance = to_player.length()
	
	if distance < repel_distance:
		if distance != 0:
			direction = to_player.normalized()
	else:
		change_timer -= delta
		if change_timer <= 0:
			if randi() % 2 == 0:
				if (randf_range(-1, 1) > 0):
					direction.x = 1
				else:
					direction.x = -1
				direction.y = 0
			else:
				if (randf_range(-1, 1) > 0):
					direction.y = 1
				else:
					direction.y = -1
				direction.x = 0
			change_timer = change_interval
	velocity = direction * speed
	move_and_slide()
		
	var victimSize = 50
	global_position.x = clamp(global_position.x, victimSize, screen_size.x - victimSize)
	global_position.y = clamp(global_position.y, victimSize, screen_size.y - victimSize)

func victimActions(delta: float) -> void:
	victimRandomMove(delta)

func _physics_process(delta: float) -> void:
	victimActions(delta)
	
