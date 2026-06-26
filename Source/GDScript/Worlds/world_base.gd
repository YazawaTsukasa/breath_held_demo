extends Node2D
class_name WorldBase

@export var start_point: StartPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.notify_game_scene_ready(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func set_character_to_start_position(character: CharacterBase):
	if not character:
		return
	print("on_game_start set_character_to_start_position")
	var start_position: Vector2 = Vector2.ZERO
	if start_point:
		print("on_game_start start_point")
		start_position = start_point.global_position
	else:
		print("on_game_start no start_point")
	add_child(character)
	character.global_position = start_position
	print("on_game_start start_position: ", start_position)
	print("on_game_start character.global_position: ", character.global_position)