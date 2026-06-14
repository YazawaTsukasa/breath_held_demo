extends Node
class_name AttackedComponent

@export var invincibility_time:float=1.0
@export var blinking_cycle:float=0.2

var on_attacked_anime_end:Callable

var _is_invincible:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func on_attacked(attack_source_position:Vector2,force:float):
	var _owner=get_parent()
	if not is_instance_valid(_owner):
		return false
	if _is_invincible:
		print("char is invincible")
		return false
	var character=_owner as CharacterBody2D
	var rigidbody=_owner as RigidBody2D
	if character:
		_on_character_attecked(character,attack_source_position,force)
	elif rigidbody:
		_on_rigidbody_attecked(rigidbody,attack_source_position,force)
	
	# 無敵時間開始
	_start_invincibility_time()
	return true

func _on_character_attecked(
	character:CharacterBody2D,attack_source_position:Vector2,force:float
):
	var current_position:Vector2=character.global_position
	var attack_direction:Vector2=(current_position-attack_source_position).normalized()
	character.velocity+=attack_direction*force
	character.move_and_slide()

func _on_rigidbody_attecked(
	rigidbody:RigidBody2D,attack_source_position:Vector2,force:float
):
	var current_position:Vector2=rigidbody.global_position
	var attack_direction:Vector2=(current_position-attack_source_position).normalized()
	var knockback_force:Vector2=attack_direction*force
	rigidbody.apply_central_impulse(knockback_force)

# 無敵時間開始
func _start_invincibility_time():
	_is_invincible=true
	_blinking(invincibility_time)
	await get_tree().create_timer(invincibility_time).timeout
	_is_invincible=false

func is_invincible():
	return _is_invincible

# 点滅
func _blinking(blinking_time:float):
	#if not animator:
	var _owner=get_parent()
	if not is_instance_valid(_owner):
		print("Invaild Owner")
		return
	var cycle_times=blinking_time/blinking_cycle
	var tw=create_tween()
	
	tw.set_loops(round(cycle_times))
	tw.tween_callback(func():_owner.visible=false)
	tw.tween_interval(blinking_cycle/2)
	tw.tween_callback(func():_owner.visible=true)
	tw.tween_interval(blinking_cycle/2)
	tw.finished.connect(_on_blinking_end)

func _on_blinking_end():
	if on_attacked_anime_end.is_valid():
		on_attacked_anime_end.call()
