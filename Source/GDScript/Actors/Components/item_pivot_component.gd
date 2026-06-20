extends Node2D
class_name ItemPivotComponent

@export var effect_component:EffectComponent
@export var progress_bar:ProgressBar

@export var default_weapon_id:String=""
@export var min_throw_item_force:float=200.0
@export var max_throw_item_force:float=1000.0
@export var unit_throw_item_force:float=500.0

var _item:ItemBase
var _default_weapon:ItemBase=null
var _team:Team.Type

var _is_gauge_charging:bool=false
var _throw_item_gauge:float=min_throw_item_force

signal on_item_using_start
signal on_item_using_end

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_default_weapon()
	init_gauge_bar(false)

func _process(delta: float) -> void:
	_charge_throw_gauge(delta)

func set_team(team:Team.Type):
	print("Item Pivot Set Team: ",team)
	_team=team
	print("Item Pivot Set Team: ",_team)

func _init_default_weapon():
	if not default_weapon_id:
		return
	var dict=ItemFactory.create_long_range_weapon(default_weapon_id)
	#_default_weapon=dict.get("item")
	if not dict:
		dict=ItemFactory.create_melee_weapon(default_weapon_id)
		_default_weapon=dict.get("item")

func effect_to_self(effect:EffectData):
	if effect_component:
		effect_component.handle_effect(effect)

func set_item(new_item:ItemBase):
	print("set_item")
	if new_item==null:
		print("set_default_weapon")
		new_item=_default_weapon
	#else:
	_item=new_item
	for child in get_children():
		remove_child(child)
		
		# NOTE: キャラはプレイヤーキャラではない場合、アイテムを削除
		if not ComponentTool.is_parent_player(get_parent()):
			print("Delete Item")
			child.queue_free()
		
	if is_instance_valid(new_item):
		await get_tree().physics_frame
		if new_item.get_parent()==null:
			add_child(new_item)
		new_item.process_on_held(self,_team)
		#new_item.reparent(item_pivot)
		var prop=new_item as PropBase
		if prop:
			prop.be_used=_prop_be_used
		
		new_item.on_using_start=_on_item_using_start
		new_item.on_using_end=_on_item_using_end
		
	return true


func throw_out_item(force:Vector2):
	if not _item or _item==_default_weapon:
		return
	var ori_holder=get_parent()
	_item.throw_out(ori_holder,force)
	
	# プレイヤーキャラの場合、プレイヤーデータからアイテムを削除
	if ComponentTool.is_parent_player(get_parent()):
		player_data_manager.remove_item_by_instance(_item)
	#else:
	set_item(null)

func use_item(using_type:String):
	if not _item:
		return
	print("use_item")
	_item.use(using_type)

# 道具が使われた際に、効果をEffectComponentに処理させて、道具を削除
func _prop_be_used(effect:EffectData):
	if effect_component:
		effect_component.handle_effect(effect)
	_delete_item()

func _delete_item():
	print("Delete Item")
	#if _is_parent_player():
	if ComponentTool.is_parent_player(get_parent()):
		player_data_manager.remove_item_by_instance(_item)
	#_item=null
	set_item(null)
	for child in get_children():
		remove_child(child)
		child.queue_free()

func start_throw_gauge():
	if not _item or _item==_default_weapon:
		return
	init_gauge_bar(true)
	
func _charge_throw_gauge(delta:float):
	if not _is_gauge_charging:
		return
	_throw_item_gauge+=unit_throw_item_force*delta
	if _throw_item_gauge>max_throw_item_force:
		_throw_item_gauge=max_throw_item_force
	_update_gauge_bar()
func end_throw_gauge():
	if not _is_gauge_charging:
		return
	_is_gauge_charging=false
	
	var mouse_position=get_global_mouse_position()
	var start_position=global_position
	var throw_force=(mouse_position-start_position).normalized()*_throw_item_gauge
	print("throw_force: ",throw_force)
	
	throw_out_item(throw_force)
	
	init_gauge_bar(false)

func init_gauge_bar(activity:bool):
	if not progress_bar:
		return
	_throw_item_gauge=min_throw_item_force
	if progress_bar:
		progress_bar.min_value=min_throw_item_force
		progress_bar.max_value=max_throw_item_force
		progress_bar.value=_throw_item_gauge
		progress_bar.visible=activity
	_is_gauge_charging=activity

func _update_gauge_bar():
	if not progress_bar:
		return
	progress_bar.value=_throw_item_gauge

func change_rotation(angle:float):
	rotation=angle

func change_rotation_by_direction(direction:Vector2,offset:float=-PI/2):
	rotation = direction.angle()+offset

func _on_item_using_start():
	on_item_using_start.emit()

func _on_item_using_end():
	print("_on_item_using_end")
	on_item_using_end.emit()
