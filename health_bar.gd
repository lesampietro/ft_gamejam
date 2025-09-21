extends Node2D
class_name HealthBar

@onready var progress_bar = $ProgressBar
@export var bar_width: float = 50.0
@export var bar_height: float = 8.0




signal health_changed(current: int, maximum: int)






func update_health(current: int, maximum: int):
	if maximum <= 0:
		return
	progress_bar.value	= current
	#var percentage = (float(current) / float(maximum)) * 100
	#progress_bar.value = percentage
	#
	## Emite sinal para outras barras
	#health_changed.emit(current, maximum)
	#
	## Muda cor baseado na vida
	#if percentage > 60:
		#progress_bar.tint_progress = Color.GREEN
	#elif percentage > 30:
		#progress_bar.tint_progress = Color.YELLOW
	#else:
		#progress_bar.tint_progress = Color.RED
