extends Level
class_name Level15

func on_initial() -> Array[Item]:
	var a:="stone"
	var b:="iron"
	var c:="gold"
	var d:="silver"
	var e:="diamond"
	var f:="gold_nugget"
	return[
		Item.a(Item.a2(a,b),Item.t(Item.a2(b,d),Item.u(c),"Goldminer")),
		Item.t(Item.u(a),Item.t2(b,a,"Backster"),"Refiller"),
		Item.t(Item.u(b),Item.t2(a,d,"Forwarder"),"Multiplexer"),
		Item.t(Item.t(Item.a2(b,d),Item.u(c),"Goldminer"),Item.a(Item.t(Item.a2(b,d),Item.u(c),"Goldminer"),Item.u(e)),"Duplicator"),
		Item.t(Item.t(Item.a2(b,d),Item.u(c),"Goldminer"),Item.a(Item.t(Item.u(c),Item.a2(b,d),"Extractor"),Item.u(f)),"Reverser"),
		Item.t(Item.a2(e,d),Item.a2(b,a),"Descender"),
		Item.ta2(c,e,"God"),
		Item.ta2(e,d,"Sid"),
		Item.ta2(a,b,"Poor"),
		Item.ta2(b,a,"Roop"),
		Item.ta2(b,d,"Ironsilver")
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Union Exam"
	self.level_no="2-5"
	self.win=Item.a2("gold","diamond","God")
	self.import_packages()
	self.desc="""
This is the final exam of Chapter 2. Can you do it?
"""
