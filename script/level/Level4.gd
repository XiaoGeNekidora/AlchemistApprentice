extends Level
class_name Level4

func on_initial() -> Array[Item]:
	return [
		Item.u("stone"),
		Item.t(Item.u("stone"),Item.t(Item.u("iron"),Item.t2("stone","silver"),"Ipe"),"Pipe"),
		Item.t(Item.u("stone"),Item.t(Item.t2("stone","iron"),Item.u("gold"),"Piz"),"Ppiz"),
		Item.t(Item.u("silver"),Item.t2("gold","diamond","Zk"),"Ezk"),
		Item.t(Item.u("stone"),Item.t(Item.u("stone"),Item.t2("stone","iron","Rx"),"Arx"),"Aarx"),
	]

func on_restock() -> Array[Item]:
	return [Item.u("stone")]

func _init():
	self.name="Purifying the Dirty"
	self.level_no="4"
	self.win=Item.u("diamond")
	self.desc="""
In this class we are no longer stopping on gold, which a first-grader can do. 
Could you believe that, diamond, the masterpiece of nature, could also be manufactured by the hand of human with wisdom and diligence.
Try to conquer the nature!

Hint: All levels are unlocked by default. If you cannot solve this level, you can try the next level!
"""
