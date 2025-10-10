extends Level
class_name Level11

func on_initial() -> Array[Item]:
	return [
		Item.a2("iron","silver","Is"),
		Item.a2("silver","gold","Sg"),
		Item.ta(Item.u("iron"),Item.u("gold"),"Ig")
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Introduction to Mixture"
	self.level_no="2-1"
	self.win=Item.a2("iron","gold","Ig")
	self.desc="""
Welcome to the second year of your alchemy lessons! Luckily you did not blow yourself up in the first year.
In this year we will be learning two new types of matter: ~Mixture~ and ~Entanglement~.
In this chapter, you will be learning ~Mixture~ first and in the next chapter you will be taught what ~Entanglement~ is.

A ~Mixture~ is just a combination of two items. You can always convert them into two separate items on the table then [wack]click[] the Break button.
On the other hand, not every pair of items can be converted to mixtures. You need a catalyst to do that. The usage is the same as before.
"""
