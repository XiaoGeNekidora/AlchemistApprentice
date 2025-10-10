extends Node

var current_level: Level = Level1.new()

var active_material: Item = null
var active_potion: Item = null

var active_material_actor:ItemDisplay=null
var active_potion_actor:ItemDisplay=null

var danger=false

# 注册方法：第一步写LevelX.gd，第二步在这里注册，第三步在Level_Select里面加入panel

var all_levels={
	"1":Level1,
	"2":Level2,
	"3":Level3,
	"4":Level4,
	"5":Level5,
	"11":Level11
}

var desc:Dictionary = {
	"stone" : "Yep. I am a rock.",
	"gold": "With this, you are gonna be rich!... If not everyone can do alchemy.",
	"iron_nugget": "It is worthless.",
	"gold_nugget": "It IS gold technically speaking, but not the form you wanted.",
	"iron": "This is NOT silver.",
	"diamond": "It's shining!!!",
	"silver": "This is NOT iron."
}
