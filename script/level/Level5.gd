extends Level
class_name Level5

func on_initial() -> Array[Item]:
	return [
		Item.t(Item.t2("stone","iron"),Item.t(Item.t2("iron","silver"),Item.u("diamond"))),
		Item.t(Item.u("iron_nugget"),Item.t(Item.u("gold_nugget"),Item.t2("stone","iron"))),
		Item.t(Item.t2("iron_nugget","silver"),Item.t(Item.t2("iron","iron_nugget"),Item.t2("iron","silver"))),
		Item.t2("iron_nugget","silver"),
		Item.t2("iron","iron_nugget"),
		Item.u("iron_nugget"),
		Item.u("gold_nugget")
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Material Gourmet"
	self.level_no="5"
	self.win=Item.u("diamond")
	self.desc="""
This is the final exam of Chapter 1. Hope you enjoy!
"""
