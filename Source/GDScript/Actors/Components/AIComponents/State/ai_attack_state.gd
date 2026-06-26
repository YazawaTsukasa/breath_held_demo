extends AIStateBase
class_name AIAttackState
	
func _init(ai_controller: AIController) -> void:
	super(ai_controller)
	_name = "AIAttackState"
	_handle_registry["end_melee_attack"] = "_end_melee_attack"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func enter():
	super()
	_melee_attack()

func exit():
	super()
	_end_melee_attack()

func _melee_attack():
	if not _ai_controller:
		return
	_ai_controller.start_melee_attack()

func _end_melee_attack():
	print("_end_melee_attack")
	if not _ai_controller:
		return
	_ai_controller.end_melee_attack()
