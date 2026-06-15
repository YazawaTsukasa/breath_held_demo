extends Node
class_name ResourceManager

var _datatable_resource_ref_registry:Dictionary={
	"effect":"res://Source/Resource/Effect/effect_datatable.tres",
	"player_property":"res://Source/Resource/PlayerProperty/player_property_datatable.tres",
	"melee_weapon":"res://Source/Resource/Item/melee_weapon_datatable.tres",
	"long_range_weapon":"res://Source/Resource/Item/long_range_weapon_datatable.tres",
	"prop":"res://Source/Resource/Item/prop_datatable.tres",
	"projectile":"res://Source/Resource/Item/projectile_datatable.tres"
}
var _datatable_resource_class_registry:Dictionary={
	"effect":EffectDatatable,
	"player_property":PlayerPropertyDatatable,
	"melee_weapon":MeleeWeaponDatatable,
	"long_range_weapon":LongRangeWeaponDatatable,
	"prop":PropDatatable,
	"projectile":ItemDatatable
}
var _datatable_resource:Dictionary={}

var _data_asset_resource_ref_registry:Dictionary={
	"player_data":"res://Source/Resource/PlayerData/player_data_asset.tres"
}
var _data_asset_resource_class_registry:Dictionary={
	"player_data":PlayerDataAsset
}
var _data_asset_resource:Dictionary={}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ResourceManager Ready")
	_load_all_datatable_resource()
	_load_all_data_asset_resource()

func _load_all_datatable_resource():
	for res_name in _datatable_resource_ref_registry.keys():
		var result=_load_datatable_resource_by_name(res_name)
		print("Load Resource: ",res_name," Is Successed: ",result)

func _load_datatable_resource_by_name(res_name:String):
	if not res_name in _datatable_resource_ref_registry:
		return false
	if res_name in _datatable_resource:
		return true
	var ref=_datatable_resource_ref_registry.get(res_name)
	var resource=load(ref) #失敗の場合 "null"が戻り
	if not resource:
		return false
	var result=false
	if res_name in _datatable_resource_class_registry:
		var cls=_datatable_resource_class_registry.get(res_name)
		if is_instance_of(resource,cls): result=true
		else: result=false
	else:
		result=true
	if result: _datatable_resource[res_name]=resource
	return result

func get_datatable_resource(res_name:String):
	if not res_name in _datatable_resource:
		return null
	return _datatable_resource.get(res_name)

func _load_all_data_asset_resource():
	for res_name in _data_asset_resource_ref_registry.keys():
		var result=_load_data_asset_resource_by_name(res_name)
		print("Load Resource: ",res_name," Is Successed: ",result)

func _load_data_asset_resource_by_name(res_name:String):
	if not res_name in _data_asset_resource_ref_registry:
		return false
	if res_name in _data_asset_resource:
		return true
	var ref=_data_asset_resource_ref_registry.get(res_name)
	var resource=load(ref) #失敗の場合 "null"が戻り
	if not resource:
		return false
	var result=false
	if res_name in _data_asset_resource_class_registry:
		var cls=_data_asset_resource_class_registry.get(res_name)
		if is_instance_of(resource,cls): result=true
		else: result=false
	else:
		result=true
	if result: _data_asset_resource[res_name]=resource
	return result

func get_data_asset_resource(res_name:String):
	if not res_name in _data_asset_resource:
		return null
	return _data_asset_resource.get(res_name)
