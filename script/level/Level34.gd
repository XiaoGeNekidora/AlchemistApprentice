extends Level
class_name Level34

func on_initial() -> Array[Item]:
	var a := 'stone'
	var b := 'iron'
	var c := 'silver'
	var d := 'gold'
	var e := 'diamond'
	return [
		Item.n(Item.o2(a,b,"Starter Kit")),
		Item.n(Item.o2(a,b,"Starter Kit")),
		Item.t(Item.n2(a),Item.n(Item.o2(c,d,"VIP Kit"))),
		Item.t(Item.n2(c),Item.n2(e))
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Drowned in the Ocean of Darkness"
	self.level_no="4-4"
	self.win=Item.a(Item.n2("stone"),Item.n2("diamond"))
	self.allowed_methods.append(GameRoot.OperationMode.PACKAGE)
	self.allowed_methods.append(GameRoot.OperationMode.UNPACKAGE)
	self.allowed_methods.append(GameRoot.OperationMode.ENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.DARK_INFUSE)
	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.desc="""
Great news! We've got out hands on one [jit]UPB (Universal Potion Brewer)[]!
We are writing textbooks so you can use it next semester!
For now, just ~LEARN~!

*How many mages are going to lose jobs due to this. Sigh...*

Oh! I almost forgot to introduce the ~Tautologizer~! It is a weird machine, when fed any substance A, it will create a potion that transforms it to ... itself!?!? (A->A)
The machine can also run without any input, which will produce a potion related to the exercise target/goal.
It might help the entangler...?
"""
