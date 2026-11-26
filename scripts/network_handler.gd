extends Node2D

const MAINMENU = preload("uid://bj036ei1co418")

const IP_ADDRESS = "127.0.0.1"
const PORT := 7583

var CONNECTED := false
var socket: WebSocketPeer 
var current_scene: Control = null

func start_client() -> bool:
	if socket != null and socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		return false
	socket = WebSocketPeer.new()
	var err := socket.connect_to_url("ws://" + IP_ADDRESS + ":" + str(PORT))
	CONNECTED = true
	if err != OK:
		push_error("connect failed: %d" % err)
		CONNECTED = false
	return true

func handle_message(text: String) -> void:
	var json = JSON.parse_string(text)
	if typeof(json) != TYPE_DICTIONARY:
		return
	var type = json.get("type", "")
	var args = json.get("args", "")
	if type == "match_found":
		if current_scene and current_scene.has_signal("match_found"):
			current_scene.emit_signal("match_found")

func send_to_server(type: String, args: Array = []) -> bool:
	if socket == null:
		return false
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		push_warning("not connected, dropped: %s" % type)
		CONNECTED = false
		return false
	socket.send_text(JSON.stringify({"type": type, "args":args}))
	return true 

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if socket != null:
		socket.poll()
		var state := socket.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count() > 0:
				var text := socket.get_packet().get_string_from_utf8()
				var msg = JSON.parse_string(text)
				if typeof(msg) != TYPE_DICTIONARY:
					push_warning("server sent invalid JSON: %s" % text)
					handle_message(text)
		elif state == WebSocketPeer.STATE_CLOSED and CONNECTED:
			print("disconnected (code %d): %s" % [socket.get_close_code(), socket.get_close_reason()])
			CONNECTED = false
