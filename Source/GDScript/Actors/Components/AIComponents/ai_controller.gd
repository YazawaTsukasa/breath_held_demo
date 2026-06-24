extends Node
class_name AIController

@export var item_pivot:ItemPivotComponent
@export var sensor:SensorComponent
@export var movement:MovementComponent
@export var hp_component:HPComponent

@export var initial_state:String="idle"

@export var melee_attack_cooldown:float=1.0

var state_ragistry:Dictionary={
	#"default":AIIdleState,
	"idle":AIIdleState,
	"chase":AIChaseState,
	"attack":AIAttackState,
	"stunned":AIStunnedState,
	"dead":AIDeadState,
}
var _default_state=AIIdleState

var _current_state:AIStateBase
var _targets:Array[Node2D]=[]

signal on_target_sensored
signal on_target_lost


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_switch_to_initial_state()
	_init_owner()
	_init_sensor()
	_init_item_pivot()
	_init_hp_component()

func _init_owner():
	var _owner=ComponentTool.get_parent_character(self)
	if _owner:
		_owner.on_direction_vector_changed=_on_direction_vector_changed

func _on_direction_vector_changed(direction:Vector2):
	if sensor:
		sensor.rotate_areas(direction)
	if item_pivot:
		item_pivot.change_rotation_by_direction(direction)

func switch_state(state_name:String=""):
	if _current_state:
		_current_state.exit()
	_current_state=\
		state_ragistry.get(
			state_name,_default_state).new(self)
	if _current_state:
		_current_state.enter()

func _switch_to_initial_state():
	switch_state(initial_state)

func _init_item_pivot():
	if not item_pivot:
		return
	#item_pivot.on_item_using_start.connect()
	item_pivot.on_item_using_end.connect(_start_cooldown)

func _init_hp_component():
	if not hp_component:
		return
	hp_component.hp_become_zero.connect(_on_hp_zero)

func _init_sensor():
	if not sensor:
		return
	sensor.on_target_sensored=_on_target_sensored
	sensor.on_target_lost=_on_target_lost
	sensor.on_melee_body_entered=_on_melee_body_entered
	sensor.on_melee_body_exited=_on_melee_body_exited

func _on_target_sensored(body):
	if not is_instance_valid(body):
		return
	var character=body as CharacterBase
	if character:
		if body not in _targets:
			_targets.append(body)
		on_target_sensored.emit(body)

func _on_target_lost(body):
	#print("AI _on_target_lost")
	if not is_instance_valid(body):
		return
	_targets.erase(body)
	#print("_targets size: ",_targets.size())
	on_target_lost.emit(body)

func _on_melee_body_entered(_body):
	#print("AI on_melee_body_entered")
	if _current_state:
		_current_state.handle_action("start_melee_attack")
	
func _on_melee_body_exited(_body):
	#print("AI on_melee_body_exited")
	if _current_state:
		_current_state.handle_action("end_melee_attack")

func start_moving_to_first_targer():
	if _targets.size()==0:
		return false
	var first_targer=_targets[0]
	if movement and is_instance_valid(first_targer):
		#print("has first target")
		movement.move_toward(first_targer)
		return true
	return false

func stop_moving():
	if movement:
		movement.stop_moving()

var timer:SceneTreeTimer
var _melee_attacking:bool= false
func start_melee_attack():
	if _melee_attacking:
		return
	_melee_attacking = true
	if timer!=null and timer.time_left>0:
		await timer.timeout
	if not _melee_attacking:
		return
	_melee_attack()
	#while _melee_attacking:
		#_melee_attack()
		#timer = get_tree().create_timer(melee_attack_cooldown)
		#await timer.timeout

func _melee_attack():
	if _melee_attacking:
		if not item_pivot:
			return
		item_pivot.use_item("special_using")

func _start_cooldown():
	print("_start_cooldown")
	timer = get_tree().create_timer(melee_attack_cooldown)
	await timer.timeout
	_melee_attack()
	
func end_melee_attack():
	_melee_attacking = false

func _on_hp_zero():
	print("AI _on_hp_zero")
	switch_state("dead")
