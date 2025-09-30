extends Node

var current_level: Level = Level1.new()

var active_material: Item = null
var active_potion: Item = null

var active_material_actor:ItemDisplay=null
var active_potion_actor:ItemDisplay=null

var danger=false

var desc:Dictionary = {
	"stone" : "Yep. I am a rock.",
	"gold": "With this, you are gonna be rich!... If not everyone can do alchemy."
}
