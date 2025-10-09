extends Level
class_name Level3

func on_initial() -> Array[Item]:
	return [
		Item.u("stone"),
		Item.t2("stone","iron","A"),
		Item.t(Item.t2("stone","iron"),Item.t2("iron","gold_nugget","D"),"B"),
		Item.t(Item.t2("iron","gold_nugget"),Item.t2("gold_nugget","gold","E"),"C"),
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Out of Space"
	self.level_no="3"
	self.win=Item.u("gold")
	self.desc="""
Maybe you have noticed, in last class we have seen the notation of [blue](A > B)[]. It is a shorthand notation and simply means any potion that is able to transform A into B. You will be seeing them a lot in this class.

There are no extra items this time. Considering the tuition fee, that's more than enough.
"""
