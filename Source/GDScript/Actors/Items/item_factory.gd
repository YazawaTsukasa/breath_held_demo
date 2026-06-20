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

static var INSTANCE_DATA_TYPES = {
	"melee_weapon": MeleeWeaponInstanceData,
	"long_range_weapon": LongRangeWeaponInstanceData,
	"prop": PropInstanceData,
	"projectile":ProjectileInstanceData
}

static func create_melee_weapon(item_id:String):
	return ItemFactory.create_item("melee_weapon",item_id)
static func create_long_range_weapon(item_id:String):
	return ItemFactory.create_item("long_range_weapon",item_id)
static func create_prop(item_id:String):
	return ItemFactory.create_item("prop",item_id)
static func create_projectile(item_id:String):
	var dict=ItemFactory.create_item("projectile",item_id)
	dict.get("item").be_projectile()
	return dict

static func create_item(
	resource_name:String,item_id:String
):
	var item_data:ItemData=\
		ItemFactory._get_item_data(
			resource_name,item_id)
	if not item_data:
		return null
	
	var item_instance_data=\
		ItemFactory.create_instance_data(
			resource_name,item_id,item_data)
		
	var ref=item_data.tscn_reference
	var scene:Resource=load(ref)
	if not scene:
		return null
	var item=scene.instantiate()
	var result=_init_item_by_resource_name(item,item_instance_data)
	if not result:
		push_warning("Item(ID:",item_instance_data.get_item_id(),") CANNOT Initialized")
	return {"item":item,"instance_data":item_instance_data}

static func create_instance_data(
	type_name:String,item_id:String,origin_data:ItemData
):
	var script=ItemFactory.INSTANCE_DATA_TYPES.get(type_name)
	if script==null:
		return null
	return script.new(item_id,origin_data)

static func create_melee_weapon_by_instance_data(
	instance_data:ItemInstanceData
):
	return ItemFactory.create_item_by_instance_data(
		"melee_weapon",instance_data)
static func create_long_range_weapon_by_instance_data(
	instance_data:ItemInstanceData
):
	return ItemFactory.create_item_by_instance_data(
		"long_range_weapon",instance_data)
static func create_prop_by_instance_data(
	instance_data:ItemInstanceData
):
	return ItemFactory.create_item_by_instance_data(
		"prop",instance_data)
static func create_projectile_by_instance_data(
	instance_data:ItemInstanceData
):
	var dict=ItemFactory.create_item_by_instance_data(
		"projectile",instance_data)
	dict.get("item").be_projectile()
	return dict
	
static func create_item_by_instance_data(
	resource_name:String,instance_data:ItemInstanceData
):
	if not is_instance_of(
		instance_data,
		ItemFactory.INSTANCE_DATA_TYPES.get(
			resource_name,ItemInstanceData)
	):
		return null
	var item_data:ItemData=\
		ItemFactory._get_item_data(
			resource_name,instance_data.get_item_id())
	if not item_data:
		return null
		
	var ref=item_data.tscn_reference
	var scene:Resource=load(ref)
	if not scene:
		return null
	var item=scene.instantiate()
	var result=_init_item_by_resource_name(item,instance_data)
	if not result:
		push_warning("Item(ID:",instance_data.get_item_id(),") CANNOT Initialized")
	return {"item":item,"instance_data":instance_data}

static func get_melee_weapon_data(item_id:String):
	var origin_data=ItemFactory._get_item_data("melee_weapon",item_id)
	return MeleeWeaponInstanceData.new(item_id,origin_data)
static func get_long_range_weapon_data(item_id:String):
	var origin_data=ItemFactory._get_item_data("long_range_weapon",item_id)
	return LongRangeWeaponInstanceData.new(item_id,origin_data)
static func get_prop_data(item_id:String):
	var origin_data=ItemFactory._get_item_data("prop",item_id)
	return PropInstanceData.new(item_id,origin_data)
static func get_projectile_data(item_id:String):
	var origin_data=ItemFactory._get_item_data("projectile",item_id)
	return ProjectileInstanceData.new(item_id,origin_data)
	
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
	#item:ItemBase,item_id:String,item_data:ItemData
	item:ItemBase,item_instance_data:ItemInstanceData
):
	if not item or not item_instance_data:
		return false
	item.init_property_by_data(item_instance_data)
	return true

static func check_global_resource_class(res:Resource, target_class_name: String) -> bool:
	if not res or not res.get_script():
		# 如果资源没有脚本，就退化去监测它的 C++ 内置类型（比如 "Resource"、"Texture2D"）
		return res.is_class(target_class_name) if res else false
		
	var script: GDScript = res.get_script()
	
	# 拿到该脚本在全局注册的 class_name
	var global_name = script.get_global_name()
	
	return global_name == StringName(target_class_name)
