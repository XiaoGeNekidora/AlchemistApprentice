extends Level
class_name Level2

func on_initial() -> Array[Item]:
	return [
		Item.u("stone"),
		Item.t(Item.u("stone"),Item.t2("stone","gold_nugget","Z"),"X"),
		Item.t2("gold_nugget","gold","Y")
	]

func on_restock() -> Array[Item]:
	return [Item.u("stone")]

func _init():
	self.win=Item.u("gold")
	self.desc="""

Target: Get [white]Gold[]
"""
