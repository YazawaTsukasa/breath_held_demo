extends WeaponBase
class_name LongRangeWeaponBase

@export var projectile_pivot:Node2D
@export var projectile_value_label:Label
@export var reload_progress_bar:ProgressBar

var _ammunition_capacity:int
var _reload_time:float
#var _is_individual_reload:bool=false
var _reload_num_once:int
var _projectile_id:String=""
var _initial_launch_force:float=500.0

# リロードした飛翔体
var _projectiles:Array[ItemBase]=[]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	using_registry["reload"]="_start_reload"
	_updata_projectile_value_label()
	if reload_progress_bar:
		reload_progress_bar.visible=false

func init_property_by_data(item_id:String,item_data:ItemData):
	super(item_id,item_data)
	var long_range_weapon_data=item_data as LongRangeWeaponData
	if not long_range_weapon_data:
		return
	_ammunition_capacity=max(long_range_weapon_data.ammunition_capacity,1)
	_reload_time=long_range_weapon_data.reload_time
	#_is_individual_reload=long_range_weapon_data.is_individual_reload
	_reload_num_once=max(long_range_weapon_data.reload_num_once,1)
	_projectile_id=long_range_weapon_data.projectile_id
	_initial_launch_force=long_range_weapon_data.initial_launch_force

var _is_reloading:bool=false
var _reload_cancelled:bool=false
func cancel_reload():
	if _is_reloading:
		_reload_cancelled=true
	
func _start_reload():
	print("start_reload")
	if _is_reloading:
		return
	_is_reloading=true
	for i in range(_ammunition_capacity-_projectiles.size()):
		if not _check_can_reload():
			break
		if _reload_time>0.0:
			_start_reload_progress_bar(_reload_time)
			var timer=get_tree().create_timer(_reload_time)
			await timer.timeout
			#if not is_instance_valid(self): # このノードはAliveなのか
				#_is_reloading=false
				#_end_reload_progress_bar()
				#return
			if _reload_cancelled:
				_reload_cancelled=false
				_end_reload_progress_bar()
				break
		_end_reload_progress_bar()
		if not _reload_once():
			break
	_is_reloading=false
	_loading()
	print("projectile num: ",_projectiles.size())

func _check_can_reload():
	return player_data_manager.has_item_by_id(_projectile_id)

func _reload_once():
	print("reload_once")
	for _i in _reload_num_once:
		var projectile=null
		# NOTE: 飛翔体の源の違い
		if _team==Team.Type.PLAYER:
			projectile=player_data_manager.pop_first_item_by_id(_projectile_id)
		else:
			projectile=ItemFactory.create_projectile(_projectile_id)
		
		if not projectile:
			return false
		print("reload")
		_projectiles.append(projectile)
		
		_updata_projectile_value_label()
	return true

func _loading():
	if _projectiles.size()>0:
		await _set_projectile_to_pivot(_projectiles[0])

func _set_projectile_to_pivot(projectile:ItemBase):
	if not projectile_pivot:
		return false
	var children=projectile_pivot.get_children()
	if children.size()>0:
		return false
	for child in children:
		projectile_pivot.remove_child(child)
	await get_tree().physics_frame
	if projectile.get_parent()==null:
		projectile_pivot.add_child(projectile)
	projectile.process_on_held(self,_team)
	return true

func _normal_attack():
	_on_using_start()
	_launch_projectile()
	_on_using_end()

func _launch_projectile():
	if _is_reloading:
		return
	print("launch_projectile")
	if _projectiles.size()<=0:
		push_warning("No Projectile")
		
	_on_using_start()
	var launch_direction=global_transform.basis_xform(Vector2(0,1))
	var projectile=_projectiles[0]
	_projectiles.erase(projectile)
	projectile.set_throw_attack_power_correction(_attack_power)
	projectile.throw_out(
		self,launch_direction*_initial_launch_force)
	_on_using_end()
	
	_loading()
	_updata_projectile_value_label()

func _set_projectile_value_label(value:String):
	if not projectile_value_label:
		return
	projectile_value_label.text=value

func _updata_projectile_value_label():
	if not _projectiles:
		_set_projectile_value_label("0")
	var _text=str(_projectiles.size())
	_set_projectile_value_label(_text)

var _progress_bar_tween:Tween=null
func _start_reload_progress_bar(reload_time:float):
	if not reload_progress_bar:
		return
	reload_progress_bar.min_value = 0.0
	reload_progress_bar.value = 0.0
	reload_progress_bar.max_value = 100.0
	reload_progress_bar.visible=true
	
	_progress_bar_tween = create_tween()
	
	# tween.tween_property(対象, "プロパティ名", 目標値, 続く時間)
	_progress_bar_tween.tween_property(
		reload_progress_bar, "value", 100.0, reload_time)
	#_progress_bar_tween.finished.connect(_end_reload_progress_bar)
	
func _end_reload_progress_bar():
	if _progress_bar_tween:
		_progress_bar_tween.kill()
		_progress_bar_tween=null
	if not reload_progress_bar:
		return
	reload_progress_bar.visible=false
