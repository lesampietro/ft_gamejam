extends Node2D

@export var next_scene_path := "res://player.tscn"
@onready var anim = $Control/AnimationPlayer

func _ready():
	anim.play("opening")
	anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(anim_name):
	if anim_name == "opening":
		get_tree().change_scene_to_file(next_scene_path)
