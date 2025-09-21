extends CharacterBody2D

@export var speed = 200
@export var damage = 5
@export var knockback_force = 300

var screen_size: Vector2
var change_timer = 0.0
var change_interval = 0.5
var direction = Vector2.ZERO
enum states_enemy { WATCH, CHASE, COMEBACK }
var state_enemy = states_enemy.WATCH

# Sistema de dano
var can_damage = true
var damage_cooldown = 1.5
var damage_timer = 0.0

# Sistema de COMEBACK
var comeback_timer = 0.0
var comeback_duration = 2.0  # Tempo em segundos para voltar ao WATCH

var player: Node2D = null
var chasing: bool = false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	$enemy_sprites.play()
	state_enemy = states_enemy.WATCH

func _physics_process(delta: float) -> void:
	# Cooldown do dano
	if not can_damage:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			can_damage = true
			damage_timer = 0.0
	# Lógica por estado
	match state_enemy:
		states_enemy.WATCH:
			handle_watch_state()

		states_enemy.CHASE:
			handle_chase_state(delta)

		states_enemy.COMEBACK:
			handle_comeback_state(delta)

	move_and_slide()

func handle_watch_state():
	# Enemy parado, esperando detectar player
	velocity = Vector2.ZERO

func handle_chase_state(delta):
	if chasing and player:
		var direction = (player.global_position - global_position).normalized()
		var distance = global_position.distance_to(player.global_position)

		# Se a distância for menor que 80, vai para COMEBACK
		if distance < 80 and can_damage:
			hit_player(player)
			change_to_comeback_state()
			return

		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

func handle_comeback_state(delta):
	# Incrementa o timer
	comeback_timer += delta
	# Se o timer acabou, volta para WATCH
	if comeback_timer >= comeback_duration:
		change_to_watch_state()
		return

	# Se ainda tem player, continua se afastando
	if player:
		var direction = (global_position - player.global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

func change_to_comeback_state():
	state_enemy = states_enemy.COMEBACK
	comeback_timer = 0.0  # Reseta o timer
	chasing = false

func change_to_watch_state():
	state_enemy = states_enemy.WATCH
	comeback_timer = 0.0  # Reseta o timer
	chasing = false
	player = null  # Perde a referência do player

func change_to_chase_state():
	state_enemy = states_enemy.CHASE
	chasing = true
	comeback_timer = 0.0  # Reseta o timer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

		# Só muda para CHASE se estiver em WATCH
		if state_enemy == states_enemy.WATCH:
			change_to_chase_state()

		# Aplica dano se pode e se for o momento certo
		#if can_damage and state_enemy == states_enemy.CHASE:
			#hit_player(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		# Se estava perseguindo, volta para WATCH
		if state_enemy == states_enemy.CHASE:
			change_to_watch_state()

func hit_player(player_body):

	var groups = player_body.get_groups()
	if groups.is_empty():
		return

	var group = groups[0]

	if group == "player":
		# Aplica dano (CORRIGIDO)
		if player_body.has_method("take_damage"):
			player_body.take_damage(damage)

		# Aplica knockback (CORRIGIDO - com parâmetros)
		if player_body.has_method("apply_knockback"):
			var knockback_direction = (player_body.global_position - global_position).normalized()
			player_body.apply_knockback(knockback_direction, knockback_force)


		# Ativa cooldown (CORRIGIDO)
		can_damage = false
		damage_timer = 0.0  # Era damage_cooldown = 0
