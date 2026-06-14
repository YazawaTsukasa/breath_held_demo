extends RigidBody2D
class_name ItemBase

@export var throw_linear_damp:float=1.0
@export var safe_distance:float=50.0
@export var throw_stop_threshold:float=50.0

#@onready var Sprit:Sprite2D=get_node_or_null("Sprite2D")
#@onready var area:Area2D=get_node_or_null("Area2D")
#@onready var collision_shape:CollisionShape2D=get_node_or_null("CollisionShape2D")
@export var area:Area2D
@export var collision_shape:CollisionShape2D

enum State{
	HELD_NORMAL,
	HELD_ATTACK,
	IND_THROWN,
	IND_STATIC
}
var state_registry:Dictionary={
	"held_normal":State.HELD_NORMAL,
	#"held_attack":State.HELD_ATTACK,
	"ind_thrown":State.IND_THROWN,
	"ind_static":State.IND_STATIC,
}
# NOTE: 状態ごとにアタックの効果の変数名
var state_attack_method_registry:Dictionary={
	State.IND_THROWN:"_cause_throwing_effect",
}

var _current_state:State=State.IND_STATIC
var state_property:Dictionary={
	State.HELD_NORMAL:ItemStateData.new(false,false,false),
	#State.HELD_ATTACK:ItemStateData.new(true,false,false),
	State.IND_THROWN:ItemStateData.new(true,false,true),
	State.IND_STATIC:ItemStateData.new(true,true,true),
}

# Team
var _team:Team.Type

# 外部からアイテムを使用するメソッドの登録表
var using_registry:Dictionary={
	"normal_using":"",
	"special_using":"",
}

# 使用中なのか
var _is_using:bool=false

# 飛翔体なのか
var _is_projectile:bool=false

# ItemData
var _item_id:String
var _item_name:String
var _normal_effect:String
var _special_effect:String
var _icon:Texture2D=null
var _throw_angular_velocity:float
var _throw_attack_effect:String
var _throw_attack_power:int  # 投擲攻撃力

# 投擲攻撃力補正
# NOTE: 普通は遠距離武器から飛翔体に遠距離武器の攻撃力
# NOTE: 投擲が停止になるとゼロになる
var _throw_attack_power_correction:int=0

var on_using_start:Callable
var on_using_end:Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_scale=0.0
	rotation_degrees=0.0
	linear_damp=throw_linear_damp
	
	#_init_texture()
	_switch_area_monitoring(false)
	if area:
		area.area_entered.connect(_cause_attack)
	
func _physics_process(_delta: float) -> void:
	_check_ori_holder_distance()
	_stop_throw_out()

func process_on_held(parent:Node2D,team:Team.Type):
	if not parent:
		return
	print("process_on_held")
	_switch_state("held_normal")
	_set_team(team)
	reparent(parent)
	global_position=parent.global_position
	rotation_degrees=0.0

func process_on_ind():
	# World scene
	var scene = get_tree().current_scene
	reparent(scene)
	
func _set_team(team:Team.Type):
	_team=team

# Independent State
func _switch_state(state:String):
	_current_state=state_registry.get(state,State.IND_STATIC)
	#print("Weapon Switch State: ",_current_state)
	var property:ItemStateData=state_property.get(_current_state)
	if property==null:
		push_warning(state,"Unregistered propery !")
	_switch_area_monitoring(property.area_monitoring)
	freeze=property.freeze
	_switch_collision(property.collision)

func _check_state(state:String):
	var target_state=state_registry.get(state)
	#print("current state: ",_current_state)
	if target_state==null:
		return false
	elif target_state!=_current_state:
		return false
	else:
		return true
		
func can_pickup():
	return _check_state("ind_static")

func _switch_collision(_is_visible:bool):
	if collision_shape:
		#collision_shape.disabled=!is_visible
		collision_shape.set_deferred("disabled", !_is_visible)
	
func _switch_area_monitoring(_is_visible:bool):
	if area:
		#area.monitoring=is_visible
		area.set_deferred("monitoring", _is_visible)

# NOTE: 唯一の攻撃の与える箇所 Tempoprary
func _cause_attack(_area:Area2D):
	var hurtbox=_area as HurtboxComponent
	var character=_area.get_parent() as CharacterBase
	if not hurtbox:
		return
	if (character and character.get_team()!=_team) or not character:
		#print("Item Team: ",_team)
		#print("Character Team: ",character.get_team())
		var method_name=state_attack_method_registry.get(_current_state)
		print("method_name: ",method_name)
		if not method_name or not self.has_method(method_name):
			return
		self.call(method_name,hurtbox)
	
func _cause_throwing_effect(hurtbox:HurtboxComponent):
	if not hurtbox:
		return
	var effect:EffectData=EffectData.new()
	effect.init_by_id(_throw_attack_effect)
	# NOTE: 値=投擲攻撃力+投擲攻撃力補正+質量+効果値
	effect.set_effect_value(
		_throw_attack_power+_throw_attack_power_correction\
		+mass+effect.value)
	hurtbox.be_attacked(effect,global_position,300.0)

# NOTE: 今度の投擲攻撃力補正の設定
func set_throw_attack_power_correction(value:int):
	_throw_attack_power_correction=value

var _ori_holder:PhysicsBody2D
var _is_check_ori_holder_distance:bool=false
func throw_out(ori_holder:PhysicsBody2D,force:Vector2):
	print("Weapon Throw Out. Force:",force)
	_switch_state("ind_thrown")
	apply_impulse(force)
	angular_velocity = _throw_angular_velocity
	
	# 独立状態にさせる
	process_on_ind()
	
	if ori_holder:
		add_collision_exception_with(ori_holder)
		_ori_holder=ori_holder
		_is_check_ori_holder_distance=true

var has_started_throwed=false
func _stop_throw_out():
	if _check_state("ind_thrown"):
		if not has_started_throwed and linear_velocity.length()>throw_stop_threshold:
			has_started_throwed=true
		elif has_started_throwed and linear_velocity.length()<=throw_stop_threshold:
			has_started_throwed=false
			_switch_state("ind_static")
			print("throw_stop_threshold")
			_on_stop_throw_out()
			
func _on_stop_throw_out():
	_throw_attack_power_correction=0  # 投擲攻撃力補正の初期化

func _check_ori_holder_distance():
	if _is_check_ori_holder_distance:
		if is_instance_valid(_ori_holder):
			var dist = global_position.distance_to(_ori_holder.global_position)
			#print("dist",dist)
			if dist > safe_distance:
				remove_collision_exception_with(_ori_holder)
				_is_check_ori_holder_distance=false
				_ori_holder = null
		else:
			_is_check_ori_holder_distance=false
			_ori_holder = null

func get_icon():
	return _icon

# 外部からアイテムを使用するメソッド
func use(using_type:String):
	if _is_using:
		return
	var using_method=using_registry.get(using_type)
	if using_method!=null and has_method(using_method):
		call(using_method)

func init_property_by_data(item_id:String,item_data:ItemData):
	if not item_data:
		return
	_item_id=item_id
	_item_name=item_data.item_name
	_normal_effect=item_data.normal_effect
	_special_effect=item_data.special_effect
	_icon=item_data.icon
	mass=item_data.mass
	_throw_angular_velocity=item_data.throw_angular_velocity
	_throw_attack_effect=item_data.throw_attack_effect
	_throw_attack_power=item_data.throw_attack_power

func get_item_id():
	return _item_id

func be_projectile():
	# NOTE: 飛ぶとき、物理的な衝突は発生しない
	_is_projectile=true
	#state_property[State.IND_THROWN]=ItemStateData.new(true,false,false)

func is_projectile():
	return _is_projectile
	
func _on_using_start():
	if on_using_start.is_valid():
		on_using_start.call()

func _on_using_end():
	if on_using_end.is_valid():
		on_using_end.call()
