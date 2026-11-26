extends Control

const MATCH = preload("uid://65yassg2f5h0") as PackedScene

@onready var matchmaking: Button = %Matchmaking

signal match_found

func _ready() -> void:
	NetworkHandler.current_scene = self

func _on_matchmaking_pressed() -> void:
	NetworkHandler.start_client()
	NetworkHandler.send_to_server("start_matchmaking", [])

func _on_match_found() -> void:
	
	get_tree().change_scene_to_packed(MATCH)
