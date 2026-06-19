extends Level
class_name Level24

func on_initial() -> Array[Item]:
	var a := 'stone'
	var b := 'iron'
	var c := 'silver'
	var d := 'gold'
	var e := 'diamond'
	return [
		Item.t(Item.o2(a,b),Item.o(Item.o2(b,c),Item.u(d)),"223"),
		Item.t2(b,e,"X"),
		Item.t2(c,e,"Y"),
		Item.t2(d,e,"Z"),
		Item.u(a),
		Item.t(Item.t2(b,e),Item.t(Item.t2(c,e),Item.t(Item.o2(b,c),Item.u(e),"Hi"),"Hi Merger B"),"Hi Merger A")
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="In and out"
	self.level_no="3-4"
	self.win=Item.u("diamond")
	self.allowed_methods.append(GameRoot.OperationMode.ENTANGLE);
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.desc="""
More Exercise~
"""
