extends MeleeWeaponBase
class_name Hands

#@onready var right_hand:Sprite2D=%Right
#@onready var left_hand:Sprite2D=%Left
#@onready var right_area:Area2D=%RightArea2D
#@onready var left_area:Area2D=%LeftArea2D
@export var right_hand:Sprite2D
@export var left_hand:Sprite2D
@export var right_area:Area2D
@export var left_area:Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if right_area:
		right_area.area_entered.connect(_cause_attack)
	if left_area:
		left_area.area_entered.connect(_cause_attack)

# Override==================================================	
func _normal_attack():
	_light_punch_start()
	
func _special_attack():
	_heavy_punch_start()

func _switch_area_monitoring(_is_visible:bool):
	if left_area:
		if not _is_visible or _normal_using:
			left_area.set_deferred("monitoring", _is_visible)
	if right_area:
		if not _is_visible or _special_using:
			right_area.set_deferred("monitoring", _is_visible)
		
func _light_punch_start():
	_is_using=true
	_normal_using=true
	_switch_state("held_attack")
	_on_using_start()
	
	var tw=create_tween()
	tw.tween_property(
		left_hand,
		"position",
		Vector2(0,_thrust_distance),
		_thrust_time)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(
		left_hand,"position",Vector2.ZERO,_thrust_time)\
	.set_ease(Tween.EASE_OUT)
	# 終了コールバック
	tw.tween_callback(_light_punch_end)
func _light_punch_end():
	_switch_state("held_normal")
	_normal_using=false
	_is_using=false
	_on_using_end()
	
func _heavy_punch_start():
	_is_using=true
	_special_using=true
	_switch_state("held_attack")
	_on_using_start()
	
	var tw=create_tween()
	tw.tween_property(
		right_hand,"position",Vector2(0,_thrust_distance),_thrust_time)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(
		right_hand,"position",Vector2.ZERO,_thrust_time)\
	.set_ease(Tween.EASE_OUT)
	# 終了コールバック
	tw.tween_callback(_heavy_punch_end)
	
func _heavy_punch_end():
	_switch_state("held_normal")
	_special_using=false
	_is_using=false
	_on_using_end()
