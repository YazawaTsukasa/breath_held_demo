extends DataBase
class_name ItemData

@export var item_name:String
@export var normal_effect:String
@export var special_effect:String
@export var tscn_reference:String
@export var icon:Texture2D

@export var mass:float=1.0
@export var throw_angular_velocity:float=10.0
@export var throw_attack_effect:String="normal_damage"
@export var throw_attack_power:int=1
