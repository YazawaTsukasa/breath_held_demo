extends Object
class_name ItemFactory

static var _normal_data_class:String="ItemData"
static var _resource_name_data_class:Dictionary={
	"melee_weapon":"MeleeWeaponData",
	"long_range_weapon":"LongRangeWeaponData",
	"prop":"PropData"
}
static var _normal_datatable_class:String="ItemDatatable"
static var _resource_name_datatable_class:Dictionary={
	"melee_weapon":"MeleeWeaponDatatable",
	"long_range_weapon":"LongRangeWeaponDatatable",
	"prop":"PropDatatable"
}

static func create_melee_weapon(item_id:String):
	return ItemFactory._create_item("melee_weapon",item_id)
static func create_long_range_weapon(item_id:String):
	return ItemFactory._create_item("long_range_weapon",item_id)
static func create_prop(item_id:String):
	return ItemFactory._create_item("prop",item_id)
static func create_projectile(item_id:String):
	var item:ItemBase=ItemFactory._create_item("projectile",item_id)
	item.be_projectile()
	return item

static func _create_item(resource_name:String,item_id:String):
	var item_data:ItemData=\
		ItemFactory._get_item_data(resource_name,item_id)
	if not item_data:
		return null
	var ref=item_data.tscn_reference
	var scene:Resource=load(ref)
	if not scene:
		return null
	var item=scene.instantiate()
	var result=_init_item_by_resource_name(item,item_id,item_data)
	if not result:
		push_warning("Item(ID:",item_id,") CANNOT Initialized")
	return item

static func _get_item_data(resource_name:String,item_id:String):
	var item_datatable=\
		resource_manager.get_datatable_resource(resource_name)
	if not item_datatable:
		print("Item Fectroy, not item_datatable")
		return null
	
	var datatable_class_ref=\
		ItemFactory._resource_name_datatable_class.get(
			resource_name,ItemFactory._normal_datatable_class)
	if not ItemFactory.check_global_resource_class(item_datatable,datatable_class_ref):
		return null
	var data=item_datatable.get_data_by_id(item_id)
	
	var data_class_ref=\
		ItemFactory._resource_name_data_class.get(
			resource_name,ItemFactory._normal_data_class)
	if ItemFactory.check_global_resource_class(data,data_class_ref):
		return data
	else:
		return null

static func _init_item_by_resource_name(
	item:ItemBase,item_id:String,item_data:ItemData
):
	if not item or not item_data:
		return false
	item.init_property_by_data(item_id,item_data)
	return true

static func check_global_resource_class(res: Resource, target_class_name: String) -> bool:
	if not res or not res.get_script():
		# 如果资源没有脚本，就退化去监测它的 C++ 内置类型（比如 "Resource"、"Texture2D"）
		return res.is_class(target_class_name) if res else false
		
	var script: GDScript = res.get_script()
	
	# 拿到该脚本在全局注册的 class_name（如果是 Godot 4.3+，这非常有效）
	var global_name = script.get_global_name()
	
	return global_name == StringName(target_class_name)
