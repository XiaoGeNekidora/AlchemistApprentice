extends Level
class_name Level22

func on_initial() -> Array[Item]:
	return [
		Item.o(Item.o2("iron","silver","Axis"),Item.u("gold"),"Biscon"),
		Item.o(Item.u("silver"),Item.o2("iron","gold","Chilo"),"Dasis"),
		Item.t2("iron","diamond","Luxury 3000"),
		Item.t2("silver","diamond","Luxury 2000"),
		Item.t2("gold","diamond","Luxury 1000"),
		Item.t2("iron","diamond","Luxury 3000"),
		Item.t2("silver","diamond","Luxury 2000"),
		Item.t2("gold","diamond","Luxury 1000"),
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="3 Entanglement"
	self.level_no="3-2"
	self.win=Item.a2("diamond","diamond")
	self.import_packages()
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.desc="""
Like Mixtures, 3-object entanglements are also possible in many forms:
(A|B)|C, A|(B|C), (A|C)|B, etc. The good news is, they are nearly the same!
Let's prove them!
"""
