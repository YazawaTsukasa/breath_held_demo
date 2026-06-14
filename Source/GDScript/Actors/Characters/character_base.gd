extends CharacterBody2D
class_name CharacterBase

@onready var animator:AnimatedSprite2D=$AnimatedSprite2D
@onready var area:Area2D=$Area2D

# アイテムピボット コンポネント
@export var item_pivot:ItemPivotComponent

@export var init_direction_vector:Vector2=Vector2.ZERO

@export var max_speed:float=300.0
@export var min_end_speed:float=1.0
@export var acceleration:float=600.0
@export var deceleration:float=2000.0
@export var run_max_speed:float=500.0
@export var run_acceleration:float=1000.0
@export var turn_coefficient:float=2.0
@export var dash_speed:float=800.0
@export var dash_time:float=0.01

@export var item_angle_range:float=360.0

# Character Movement And Move Animation
var _is_running:bool=false
enum move_state{
	IDLE,
	MOVE,
	DUSH
}
var move_state_registry:Dictionary={
	"idle":move_state.IDLE,
	"move":move_state.MOVE,
	"dush":move_state.DUSH
}
var anim_name_pre_registry:Dictionary={
	move_state.IDLE:"idle_",
	move_state.MOVE:"move_",
	move_state.DUSH:"move_"
}
var _current_direction:int=3
var _current_direction_vector=Vector2(0,1)
var on_direction_vector_changed:Callable
var _current_move_state:move_state=move_state.IDLE
var _pre_move_state:move_state=_current_move_state

var _dash_timer:float=dash_time

# Team
var _team:Team.Type=Team.Type.NEUTRAL

# Subnode Initialization Complete
func _ready() -> void:
	# Direction Initialization
	#_play_move_animation_by_current()
	_init_direction_vector(init_direction_vector)
	
	if area:
		area.area_entered.connect(_on_area_entered)
	if item_pivot:
		item_pivot.set_team(_team)

# Physics Tick
func _physics_process(_delta: float) -> void:
	pass
	#if self is not MainCharacter:
		#pass
		#_process_input(Vector2.ZERO,delta)

func set_team(team:Team.Type):
	_team=team
func get_team():
	return _team

func _on_area_entered(target_area):
	#print("Character On Area Entered")
	var target = target_area.get_parent()
	if target is ItemBase and target.can_pickup():
		var parent = target.get_parent()
		if parent:
			parent.remove_child(target)
		player_data_manager.add_item(target)

func _set_move_state(state:String):
	_pre_move_state=_current_move_state
	var state_enum=move_state_registry.get(state,move_state.IDLE)
	_current_move_state=state_enum

func _rollback_move_state():
	_current_move_state=_pre_move_state	

func _check_move_state(state:String):
	var result=false
	if move_state_registry.has(state):
		var state_enum=move_state_registry.get(state)
		result=_current_move_state==state_enum
	return result

func request_to_move(direction_vector:Vector2,delta:float):
	#_change_current_direction_vector(direction_vector)
	_process_input(direction_vector,delta)

func _change_current_direction_vector(direction_vector:Vector2):
	if direction_vector==Vector2.ZERO:
		return
	_current_direction_vector=direction_vector
	if on_direction_vector_changed.is_valid():
		on_direction_vector_changed.call(_current_direction_vector)

func _init_direction_vector(direction_vector:Vector2):
	direction_vector=direction_vector.normalized()
	_change_current_direction_vector(direction_vector)
	_process_input_for_state(direction_vector)
	_play_move_animation_by_current()

func _process_input(direction_vector:Vector2,delta:float):
	_change_current_direction_vector(direction_vector)
	_process_input_for_state(direction_vector)
	_character_move(direction_vector,delta)
	_character_dush(direction_vector,delta)
	_play_move_animation_by_current()
	
func _process_input_for_state(direction_vector:Vector2):
	if _check_move_state("dush"):
		return
	var direction=_direction_handle(direction_vector)
	if direction==0:
		# idle
		_set_move_state("idle")
	else:
		# move
		_current_direction=direction
		_set_move_state("move")

func _character_move(direction:Vector2,delta:float):
	if _check_move_state("dush"):
		return
	
	#print("Is Running: ",_is_running)
	var speed = run_max_speed if _is_running else max_speed
	var accel = run_acceleration if _is_running else acceleration
	var target_velocity = direction * speed
	
	if direction == Vector2.ZERO:
		accel = deceleration
	# Emergency idle
	elif velocity.dot(target_velocity)<0:
		accel*=turn_coefficient

	velocity = velocity.move_toward(target_velocity, accel * delta)
	if velocity.length() < min_end_speed:
		velocity = Vector2.ZERO
	move_and_slide()
	
	# 走りのコールバック
	if _is_running and velocity!=Vector2.ZERO:
		_on_running(delta)

func _on_running(_delta:float):
	pass

func _character_dush(input_direction:Vector2,delta:float):
	if not _check_move_state("dush"):
		return
	if _dash_timer>0:
		var direction=\
			_current_direction_vector\
			if input_direction==Vector2.ZERO\
			else input_direction
		_dash_timer-=delta
		velocity = direction * dash_speed
		move_and_slide()
		# ダッシュのコールバック
		_on_dush()
	else:
		_rollback_move_state()
		_dash_timer=dash_time

func _on_dush():
	pass

func set_running_state(is_running:bool):
	_is_running=is_running

func dash():
	_set_move_state("dush")

# Direction To Intage
# x->y 1,2,3,4,5,6,7,8,0
func _direction_handle(direction:Vector2)->int:
	if direction.is_zero_approx():  # ゼロベクトル
		return 0
	var angle = rad_to_deg(direction.angle())
	while angle < 0:
		angle += 360
	return int(round(angle / 45.0)) % 8 + 1

func _read_current_anim_name_pre():
	return _read_anim_name_pre(_current_move_state)
	
func _read_anim_name_pre(state:move_state):
	return anim_name_pre_registry.get(state)
	
func _play_move_animation_by_current():
	var animation_direction:String=""
	var is_right:bool=false
	match _current_direction:
		1:
			animation_direction="around"
			is_right=true
		2:
			animation_direction="slanting_downward"
			is_right=true
		3:
			animation_direction="forward"
			is_right=false
		4:
			animation_direction="slanting_downward"
			is_right=false
		5:
			animation_direction="around"
			is_right=false
		6:
			animation_direction="slanting_upward"
			is_right=false
		7:
			animation_direction="back"
			is_right=false
		8:
			animation_direction="slanting_upward"
			is_right=true
	var animation_type=_read_current_anim_name_pre()
	if animation_type==null:
		push_error("Unregistered animation name prefix")
		return
	var animation_name=animation_type+animation_direction
	_play_character_animation(animation_name,is_right)

func _play_character_animation(animation_name:String,is_flip:bool=false):
	if animator==null:
		return
	animator.flip_h=is_flip
	animator.play(animation_name)
	
# Item
func set_item(new_item:ItemBase):
	if not item_pivot:
		print("not item_pivot")
		return false
	_reset_gauge_bar()
	return await item_pivot.set_item(new_item)

func _change_item_angle():
	if item_pivot==null:
		return
	
	# Mouse Position
	var mouse_position=get_global_mouse_position()
	var to_mouse_vector=mouse_position-item_pivot.global_position
	var angle=-to_mouse_vector.angle_to(Vector2(0,1))
	
	var offset = deg_to_rad(90)
	var character_angle=\
		-_current_direction_vector.angle_to(Vector2(1,0))-offset
	
	var delta=wrapf(angle-character_angle,-PI,PI)
	var max_angle=deg_to_rad(item_angle_range/2)
	var min_angle=-deg_to_rad(item_angle_range/2)
	delta=clamp(delta,min_angle,max_angle)
	var final_angle=character_angle+delta
	item_pivot.change_rotation(final_angle)
	
func _start_throw_gauge():
	if item_pivot:
		item_pivot.start_throw_gauge()
func _end_throw_gauge():
	if item_pivot:
		item_pivot.end_throw_gauge()
func _reset_gauge_bar():
	if item_pivot:
		item_pivot.init_gauge_bar(false)
