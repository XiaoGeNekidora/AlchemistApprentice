extends Level
class_name Level35

var a := 'stone'
var b := 'iron'
var c := 'silver'
var d := 'gold'
var e := 'diamond'
func on_initial() -> Array[Item]:
	return [
		Item.o(Item.n2(a), Item.n2(b),"Nihao!"),
		Item.t2(c, a),
		Item.t2(d, a),
		Item.t2(c, b),
		Item.t2(d, b),
		Item.t(Item.n(Item.o2(c, d)), Item.a2(e, a)),
		Item.t(Item.u(e), Item.a2(b, d)),
		Item.t(Item.u(d), Item.a(Item.u(a), Item.a2(b, a))),
		Item.t(Item.n(Item.o2(c, d)), Item.a(Item.n2(c), Item.n2(d))),
	]

func on_restock() -> Array[Item]:
	return [Item.o(Item.n2(a), Item.n2(b),"Nihao!")]

func _init():
	self.name="Embrace Dawn"
	self.level_no="4-5"
	self.win=Item.o(Item.a(Item.a2("stone","diamond"),Item.a2("stone","iron")),Item.a(Item.n2("silver"),Item.n2("gold")))
	self.allowed_methods.append(GameRoot.OperationMode.PACKAGE)
	self.allowed_methods.append(GameRoot.OperationMode.UNPACKAGE)
	self.allowed_methods.append(GameRoot.OperationMode.ENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.DARK_INFUSE)
	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.desc="""
This is the exam for Chapter 4.
If you have solved all 4-1 to 4-5, you are guaranteed an A already!
[red]This quest is hard. DO THIS ONLY IF YOU WANT A+[]

Restock is available in this quest.
"""
