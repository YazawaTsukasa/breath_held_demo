extends Node
class_name MovementComponent

var _is_move: bool = false
var _target: Node2D = null
var _target_position: Vector2

var _is_toward_position: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	_owner_move(delta)

func move_toward(target: Node2D):
	#print("move_toward")
	_target = target
	_is_move = true
	_is_toward_position = false

func move_toward_position(target_position: Vector2):
	_target_position = target_position
	_is_move = true
	_is_toward_position = true

func stop_moving():
	_is_move = false
	var _owner = ComponentTool.get_parent_character(self)
	if not _owner:
		return
	_owner_idle(_owner)
	
func _owner_move(delta: float):
	if not _is_move:
		return
	var _owner = ComponentTool.get_parent_character(self)
	if not _owner:
		return
	if _is_toward_position:
		_owner_move_to_position(_owner, delta)
	else:
		_owner_move_to_target(_owner, delta)

func _owner_move_to_target(_owner: CharacterBase, delta: float):
	if not is_instance_valid(_target):
		stop_moving()
	var position = _owner.global_position
	var direction = (_target.global_position - position).normalized()
	_owner.request_to_move(direction, delta)

func _owner_move_to_position(_owner: CharacterBase, delta: float):
	var position = _owner.global_position
	var direction = (_target_position - position).normalized()
	_owner.request_to_move(direction, delta)

func _owner_idle(_owner: CharacterBase):
	_owner.request_to_move(Vector2.ZERO, 0.0)
