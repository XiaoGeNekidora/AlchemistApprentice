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
	self.name="Understanding Chains"
	self.level_no="2"
	self.win=Item.u("gold")
	self.desc="""
Most of the times, direct conversion is costy due to increased labor prices and material fees. Therefore it is essential for an alchemist to [red]craft your own potion[]!

The basic rule is still the same: [darkgreen]Apply the correct catalyst on the correct base material.[]

Oh, in some tasks like this, you can [blue]Restock[] to get more items by clicking the bag again. Don't forget if you ever run out of materials!

What? You have taken too many items?? Bruh, plz hit that retry button.
"""
