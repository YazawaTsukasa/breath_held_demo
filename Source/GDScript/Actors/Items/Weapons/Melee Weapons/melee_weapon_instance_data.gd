extends ItemInstanceData
class_name MeleeWeaponInstanceData

func _init(item_id:String,origin_data:ItemData) -> void:
	super(item_id,origin_data)
	_item_type="melee_weapon"
