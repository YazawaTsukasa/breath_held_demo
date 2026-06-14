extends CharacterBase
class_name EnemyBase

func _init() -> void:
	_team=Team.Type.ENEMY
	
func _ready() -> void:
	super()
	_test_tack_weapon()

func _physics_process(delta: float) -> void:
	super(delta)

# NOTE: 
func _test_tack_weapon():
	var sword=ItemFactory.create_melee_weapon("sword")
	set_item(sword)
