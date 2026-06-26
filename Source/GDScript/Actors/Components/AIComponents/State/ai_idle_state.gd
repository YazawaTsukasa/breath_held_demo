extends AIStateBase
class_name AIIdleState

func _init(ai_controller: AIController) -> void:
	super(ai_controller)
	_name = "AIIdleState"
	if _ai_controller:
		_ai_controller.on_target_sensored.connect(_on_target_sensored)

func enter():
	super()
	_request_stop_moving()

func _request_stop_moving():
	if _ai_controller:
		_ai_controller.stop_moving()

func _on_target_sensored(_body):
	print("Idle _on_target_sensored")
	_ai_controller.switch_state("chase")
