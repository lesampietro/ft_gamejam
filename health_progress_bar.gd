extends TextureProgressBar

func _ready():
	texture_under = preload("res://ui_big_pieces.png")
	texture_progress = preload("res://ui_big_pieces.png")
	
	# Colore as texturas
	tint_under = Color.DARK_GRAY      # Fundo escuro
	tint_progress = Color.GREEN       # Barra verde
	
	min_value = 0
	max_value = 100
	value = 75
