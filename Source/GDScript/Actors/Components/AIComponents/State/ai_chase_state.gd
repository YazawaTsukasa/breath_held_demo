extends AIStateBase
class_name AIChaseState

func _init(ai_controller: AIController) -> void:
	super(ai_controller)
	_name = "AIChaseState"
	_handle_registry["start_idle"] = "_start_idle"
	_handle_registry["start_melee_attack"]="_start_melee_attack"

func enter():
	super()
	if _ai_controller:
		_ai_controller.start_moving_to_first_targer()

func exit():
	super()
	if _ai_controller:
		_ai_controller.stop_moving()

func _start_idle():
	if not _ai_controller:
		return
	_ai_controller.switch_state("idle")