extends Level
class_name Level13

func on_initial() -> Array[Item]:
	return [
		Item.a2("iron","gold","Ig"),
		Item.a2("iron","gold","Ig"),
		Item.ta(Item.u("iron"),Item.u("gold"),"Ig"),
		Item.ta(Item.u("gold"),Item.u("iron"),"Gi"),
		Item.ta(Item.a(Item.u("iron"),Item.u("gold"),"Ig"),Item.a(Item.u("gold"),Item.u("iron"),"Gi"),"Iggi")
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Swapping Places"
	self.level_no="2-3"
	self.win=Item.a(Item.a(Item.u("iron"),Item.u("gold"),"Ig"),Item.a(Item.u("gold"),Item.u("iron"),"Gi"),"Iggi")
	self.import_packages()
	self.desc="""
When a [red]Mixture[] contains two items, there are ALSO two different possible formations: AB and BA!
In your materialmagicology lessons you have learnt that there is always a DM-ELS material based on the MPP of the EL that forms the materials.
For CM family ELs, the order is natually decided by DM-ELS affinity of those PWs.

That's not our focus in this course. In this class, we show that these two forms are also interexchangable. 
"""
