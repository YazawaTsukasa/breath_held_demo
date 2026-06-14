extends Object
class_name ComponentTool

#var _parent_class_name:Array[String]=[
	#"CharacterBase",
	#"ItemBase"
#]

# コンポネントの親ノードはキャラかアイテムか検査
# Trueː キャラ　Falseː アイテム
#static func is_parent_char_or_item(parent:Node2D):
	

#static func is_parent_player

static func is_parent_player(parent:Node2D):
	if not parent:
		return false
	var character=parent as CharacterBase
	if not character:
		return false
	return character.get_team()==Team.Type.PLAYER
	
	#var player_character=parent as MainCharacter
	#if not player_character:
		#return false
	#return player_controller.check_is_player_character(
		#player_character)

static func queue_free_parent(parent:Node2D):
	#parent.get_parent().remove_child(parent)
	if parent:
		parent.queue_free()

static func get_parent_character(component:Node):
	var parent=component.get_parent()
	if not parent:
		return null
	var character=parent as CharacterBase
	return character
