extends Node2D

@export var next_scene_path := "res://opening.tscn"
@onready var anim = $Control/AnimationPlayer

func _ready():
	anim.play("title")
	anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(anim_name):
	if anim_name == "title":
		get_tree().change_scene_to_file(next_scene_path)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(next_scene_path)
