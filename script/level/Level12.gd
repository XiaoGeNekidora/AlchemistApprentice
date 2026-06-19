extends Level
class_name Level12

func on_initial() -> Array[Item]:
	return [
		Item.a(Item.u("iron"),Item.a2("silver","gold","Sg"),"Righted"),
		Item.ta(Item.u("iron"),Item.u("silver"),"Is"),
		Item.ta(Item.u("silver"),Item.u("gold"),"Sg"),
		Item.ta(Item.a2("iron","silver"),Item.u("gold"),"Lefted"),
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Lefted and Righted Mixture"
	self.level_no="2-2"
	self.win=Item.a(Item.a2("iron","silver","Is"),Item.u("gold"),"Lefted")
	self.import_packages()
	self.desc="""
When a [red]Mixture[] contains three items, there are two different possible formations: A(BC) and (AB)C.
In the nature, which one to form depends on the magic particle density nearby, the relative composing mass of the materials etc.
But in this class, we show that these two forms are interexchangable. 
"""
