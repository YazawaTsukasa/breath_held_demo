extends ItemInstanceData
class_name LongRangeWeaponInstanceData

var _projectiles_data: Array[ProjectileInstanceData] = []

func _init(item_id: String, origin_data: ItemData) -> void:
	super(item_id, origin_data)
	_item_type = "long_range_weapon"

func add_projectile(instance_data: ProjectileInstanceData):
	if instance_data in _projectiles_data:
		return
	_projectiles_data.append(instance_data)

func remove_projectile_by_instance(projectile: ItemBase):
	if not projectile.is_projectile():
		return
	var data = projectile.get_item_instance_data()
	if not data:
		return
	var projectile_data = data as ProjectileInstanceData
	if not projectile_data:
		return
	_projectiles_data.erase(projectile_data)
	
func get_projectiles_data():
	return _projectiles_data
