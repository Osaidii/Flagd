extends Node2D

const MATCH = preload("uid://65yassg2f5h0") as PackedScene

@onready var client_button: Button = %"Play Button"

func _onPlayButtonPressed() -> void:
	get_tree().change_scene_to_packed(MATCH)
