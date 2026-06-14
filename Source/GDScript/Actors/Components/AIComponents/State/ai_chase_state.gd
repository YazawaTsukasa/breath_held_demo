extends AIStateBase
class_name AIChaseState

func _init(ai_controller:AIController) -> void:
	super(ai_controller)
	_name="AIChaseState"
	if _ai_controller:
		_ai_controller.on_target_lost.connect(_on_target_lost)

func enter():
	super()
	if _ai_controller:
		_ai_controller.start_moving_to_first_targer()

func exit():
	super()
	if _ai_controller:
		_ai_controller.stop_moving()

func _on_target_lost(_body):
	print("_on_target_lost")
	if not _ai_controller:
		return
	if _ai_controller.start_moving_to_first_targer():
		return
	_ai_controller.switch_state("idle")
