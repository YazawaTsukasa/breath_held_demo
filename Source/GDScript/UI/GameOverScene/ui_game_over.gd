extends Control
class_name UIGameOver

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event):
	if event.is_pressed():
		print("Any key pressed")
		_back_to_main_menu()

func _back_to_main_menu():
	game_manager.back_to_main_menu()
