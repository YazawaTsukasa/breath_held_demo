extends WeaponBase
class_name MeleeWeaponBase

# 突き刺す攻撃
var _thrust_time:float=0.05
var _thrust_distance:float=30.0
# 斬る攻撃
var _swing_time:float=0.2
var _swing_pre_time:float=0.07
var _swing_post_time:float=0.05
var _swing_extend_forward:Vector2=Vector2(0,15)
var _swing_ini_rotation:float=-100.0 
var _swing_fin_rotation:float=100.0

var _normal_using:bool=false
var _special_using:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)

func _normal_attack():
	#print("MeleeWeaponBase simple_attack")
	_thrust_start()
	
func _special_attack():
	_swing_start()

#func _on_body_entered(body):
	#print("Sword Enter Hit !")
#
#func _on_body_exited(body):
	#print("Sword Exit Hit !")

func _thrust_start():
	_is_using=true
	_normal_using=true
	_switch_state("held_attack")
	_on_using_start()
	
	var tw=create_tween()
	tw.tween_property(
		self,"position",Vector2(0,_thrust_distance),_thrust_time)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self,"position",Vector2.ZERO,_thrust_time)\
	.set_ease(Tween.EASE_OUT)
	
	tw.tween_callback(_thrust_end)

func _thrust_end():
	_switch_state("held_normal")
	_normal_using=false
	_is_using=false
	_on_using_end()
	
func _swing_start():
	_is_using=true
	_special_using=true
	_switch_state("held_attack")
	_on_using_start()
	
	var parent_ori_rotation:float=get_parent().rotation_degrees
	var tw=create_tween()
	tw.parallel().tween_property(
		self,"position",_swing_extend_forward,_swing_pre_time)
	tw.parallel().tween_property(
		get_parent(),"rotation_degrees",
		parent_ori_rotation+_swing_fin_rotation,
		_swing_time)\
		#self,"rotation_degrees",swing_fin_rotation,swing_time)\
	.from(parent_ori_rotation+_swing_ini_rotation)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	print("start")
	tw.tween_callback(Callable(self, "_swing_after").bind(parent_ori_rotation))
	
func _swing_after(parent_ori_rotation:float):
	#print("after")
	var tw=create_tween()
	tw.parallel().tween_property(
		get_parent(),
		"rotation_degrees",
		parent_ori_rotation+0,
		_swing_post_time)\
			.from(parent_ori_rotation+_swing_fin_rotation)
	tw.parallel().tween_property(
		self,"position",Vector2.ZERO,_swing_post_time)
	tw.tween_callback(_swing_end)
	
func _swing_end():
	#print("end")
	_switch_state("held_normal")
	_special_using=false
	_is_using=false
	_on_using_end()
	
func init_property_by_data(item_id:String,item_data:ItemData):
	super(item_id,item_data)
	var melee_weapon_data=item_data as MeleeWeaponData
	if not melee_weapon_data:
		return
	_thrust_time=melee_weapon_data.thrust_time
	_thrust_distance=melee_weapon_data.thrust_distance
	_swing_time=melee_weapon_data.swing_time
	_swing_pre_time=melee_weapon_data.swing_pre_time
	_swing_post_time=melee_weapon_data.swing_post_time
	_swing_extend_forward=melee_weapon_data.swing_extend_forward
	_swing_ini_rotation=melee_weapon_data.swing_ini_rotation
	_swing_fin_rotation=melee_weapon_data.swing_fin_rotation

func _cause_attack_effect(hurtbox:HurtboxComponent):
	if not hurtbox:
		return
	super(hurtbox)
	var effect=EffectData.new()
	if _normal_using:
		effect.init_by_id(_normal_effect)
		effect.set_effect_value(_attack_power+effect.value)
	elif _special_using:
		effect.init_by_id(_special_effect)
		effect.set_effect_value(
			_attack_power*_heavy_attack_multiplier+effect.value)
	else:
		return
	hurtbox.be_attacked(effect,global_position,300.0)
