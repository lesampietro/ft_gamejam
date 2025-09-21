extends CharacterBody2D

@export var speed = 200
var screen_size: Vector2 # o tipo do retorno do screen size. x, y
var change_timer = 0.0
var change_interval = 0.5
var direction = Vector2.ZERO
#@onready var player = get_node("../Player")

var player: Node2D = null
var chasing: bool = false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	$enemy_sprites.play()

func _physics_process(delta: float) -> void:
	if chasing and player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("Corpo detectado: ", body.name, " - Grupos: ", body.get_groups())
	if body.is_in_group("player"):
		player = body
		chasing = true
		print("Enemy: player entrou na área -> começando perseguição")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		chasing = false
		player = null
		print("Enemy: player saiu da área -> parando perseguição")
