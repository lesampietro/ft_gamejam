extends CharacterBody2D

@onready var col_shape = $CollisionShape2D

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = true

func _ready() -> void:
	$bush.play()
	var movementState = "default" # Começa como Idle


func _physics_process(delta: float) -> void:
	pass
	
