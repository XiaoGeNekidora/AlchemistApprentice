extends Level
class_name Level2

func on_initial() -> Array[Item]:
	return [
		Item.new(Item.ItemType.UNIT,"stone"),
		Item.new(Item.ItemType.TRANSFORM,"stone","(stone -> gold_nugget)"),
		Item.new(Item.ItemType.TRANSFORM,"gold_nugget","gold")
	]

func on_restock() -> Array[Item]:
	return [Item.new(Item.ItemType.UNIT,"stone")]

func _init():
	self.win=Item.new(Item.ItemType.UNIT, "gold")
	self.desc="""

Target: Get [white]Gold[]
"""
