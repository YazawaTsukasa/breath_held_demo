extends RefCounted
class_name AIStateBase

var _name: String = "AIStateBase"

var _ai_controller: AIController

var _handle_registry: Dictionary = {
	"start_melee_attack": "_start_melee_attack"
}

func _init(ai_controller: AIController) -> void:
	_ai_controller = ai_controller

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_name():
	return _name

func enter():
	print("AI State: ", _name, " On Enter")
func exit():
	print("AI State: ", _name, " On Exit")

func handle_action(action: String):
	var handler = _handle_registry.get(action)
	if not handler or not has_method(handler):
		return
	var callable = Callable(self, handler)
	callable.call()

func _start_melee_attack():
	#print("_start_melee_attack")
	if not _ai_controller:
		return
	_ai_controller.switch_state("attack")
