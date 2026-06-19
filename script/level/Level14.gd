extends Level
class_name Level14

func on_initial() -> Array[Item]:
	
	var t=["iron","silver","gold","diamond"]
	
	var a:Array[Item]=[Item.a(Item.a2("diamond","iron"),Item.a2("gold","silver"),"Digs"),
		Item.ta(Item.a2("iron","silver"),Item.a2("gold","diamond"),"Isgd")
	]
	
	for i in range(len(t)):
		for j in range(i, len(t)):
			a.append(Item.ta2(t[i],t[j],t[i][0].capitalize()+t[j][0]))
	return a

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Sorting"
	self.level_no="2-4"
	self.win=Item.a(Item.a2("iron","silver"),Item.a2("gold","diamond"),"Isgd")
	self.import_packages()
	self.desc="""
Wow! A rare displaced four-element mixture! This is uncommon because usually the elements should be ~sorted~.
We can infer that some sort of distortion may have happened (like a dragon outbreak) at where this compound is taken.
Can you help our mother nature to sort it?
"""
