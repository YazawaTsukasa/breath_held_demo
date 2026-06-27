extends AIStateBase
class_name AIIdleState

func _init(ai_controller: AIController) -> void:
	super(ai_controller)
	_name = "AIIdleState"
	_handle_registry["start_chase"] = "_start_chase"
	_handle_registry["start_melee_attack"]="_start_melee_attack"

func enter():
	super()
	_request_stop_moving()

func _request_stop_moving():
	if _ai_controller:
		_ai_controller.stop_moving()

func _start_chase():
	if not _ai_controller:
		return
	_ai_controller.switch_state("chase")
