extends Node2D

const IP_ADDRESS = "127.0.0.1"
const PORT := 7583

var peer: WebSocketMultiplayerPeer

func _ready() -> void:
	start_client()

func start_client() -> bool:
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_client("ws://" + IP_ADDRESS + ":" + str(PORT))
	if err != OK:
		return false
	multiplayer.multiplayer_peer = peer
	return true
