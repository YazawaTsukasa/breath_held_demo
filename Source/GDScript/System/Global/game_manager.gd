extends Node
class_name GameManager

var test_map_scent_ref:String=\
	"res://Content/Worlds/test_world.tscn"

signal on_scene_start
#signal on_game_start
#signal on_game_over

var _current_game_scene:Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func notify_game_scene_ready(scene):
	_current_game_scene = scene
	on_scene_start.emit()

func get_current_game_scene():
	return _current_game_scene

func _change_scene(path: String):
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	print("current_scene =", get_tree().current_scene)

func start_game():
	await _change_scene(test_map_scent_ref)

func quit_game():
	get_tree().quit()

func back_to_main_menu():
	var main_scene_ref = ProjectSettings.get_setting(
		"application/run/main_scene"
	)
	_change_scene(main_scene_ref)
