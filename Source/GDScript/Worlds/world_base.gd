extends Node2D
class_name WorldBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.notify_game_scene_ready(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
