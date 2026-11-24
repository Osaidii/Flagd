extends Control

@onready var flag: TextureRect = %Flag
@onready var text_input: LineEdit = %"Text Input"
@onready var text_bg: ColorRect = %Zone
@onready var flag_name: Label = %"Flag Name"
@onready var camera: Camera2D = %Camera

const FILES_MISSING = preload("uid://b5unk6re2a6ax") as PackedScene
const COUNTRIES = "res://storage/countries.json"
const FLAGS = "res://assets/flags/"

var countries_json: Dictionary
var current_country_code: String

func validate_files() -> void: 
	if not FileAccess.file_exists(str(COUNTRIES)):
		printerr("File not found: " + str(COUNTRIES))
		get_tree().change_scene_to_packed(FILES_MISSING)
	elif not DirAccess.dir_exists_absolute(FLAGS):
		printerr("Directory not found: " + str(FLAGS))
		get_tree().change_scene_to_packed(FILES_MISSING)
	if DirAccess.get_files_at(FLAGS).size() != 508:
		printerr("Flag Files Missing")
		get_tree().change_scene_to_packed(FILES_MISSING)

func load_json() -> Dictionary:
	var file = FileAccess.open(COUNTRIES, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("JSON Parse Error: " + json.get_error_message() + " at line " + str(json.get_error_line()))
		get_tree().change_scene_to_packed(FILES_MISSING)
		return {}
	return json.data

func load_flag(country_code) -> void:
	var flag_texture: ImageTexture
	var path: String = FLAGS.path_join(country_code.to_lower() + ".png")
	current_country_code = country_code
	var image = Image.new()
	image = Image.load_from_file(path)
	flag_texture = ImageTexture.create_from_image(image)
	flag.texture = flag_texture
	flag_name.text = ""
	flag_name.text = ""

func check_answer(answer: String, country_code: String) -> bool:
	print(answer, country_code)
	var correct_answers := []
	if not countries_json["countries"].has(country_code):
		return false
	correct_answers.append(countries_json["countries"][country_code])
	if countries_json["aliases"].has(country_code):
		for alias in countries_json["aliases"][country_code]:
			correct_answers.append(alias)
	for ans in correct_answers:
		if answer.strip_edges().to_lower() == ans.to_lower():
			return true
	return false

func correct_answer() -> void:
	flag_name.text = str(countries_json["countries"][current_country_code])
	text_bg.color = Color(0.0, 1.0, 0.0, 1.0)
	await get_tree().create_timer(2.0).timeout
	text_bg.color = Color(1.0, 1.0, 1.0, 1.0)
	text_input.clear()
	text_input.grab_focus()

func wrong_answer() -> void:
	camera.screen_shake(10, 0.3)
	text_bg.color = Color(1.0, 0.0, 0.0, 1.0)
	await get_tree().create_timer(0.5).timeout
	text_bg.color = Color(1.0, 1.0, 1.0, 1.0)
	text_input.grab_focus()
	text_input.clear()

func random_country_code(exclude: String = "") -> String:
	var codes: Array = countries_json["countries"].keys()
	if exclude != "":
		codes = codes.filter(func(c): return c != exclude)
	if codes.is_empty():
		return ""
	return codes.pick_random()

func _ready() -> void:
	validate_files()
	countries_json = load_json()
	load_flag(random_country_code())

func _on_answer_submitted(new_text: String) -> void:
	if !NetworkHandler.CONNECTED:
		NetworkHandler.start_client()
	NetworkHandler.send_to_server("answer", [new_text])
	if check_answer(new_text, current_country_code):
		await correct_answer()
		load_flag(random_country_code())
	else:
		wrong_answer()
 
