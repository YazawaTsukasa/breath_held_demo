extends Node
class_name UIMainMenu

@export var start_button:Button
@export var quit_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_ui()

func _init_ui():
	if start_button:
		start_button.pressed.connect(start_game)
	if quit_button:
		quit_button.pressed.connect(quit_game)

func start_game():
	print("start_game")
	await game_manager.start_game()

func quit_game():
	print("quit_game")
	game_manager.quit_game()
