extends Level
class_name Level33

func on_initial() -> Array[Item]:
	var a := 'stone'
	var b := 'iron'
	var c := 'silver'
	var d := 'gold'
	var e := 'diamond'
	return [
		Item.a(Item.u(a),Item.n2(b)),
		Item.t(Item.n(Item.o2(c,d)),Item.u(b)),
		Item.t2(c,e),
		Item.t2(d,e)
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Find a way out of nowhere"
	self.level_no="4-3"
	self.win=Item.a2("stone","diamond")
	self.allowed_methods.append(GameRoot.OperationMode.PACKAGE)
	self.allowed_methods.append(GameRoot.OperationMode.UNPACKAGE)
	self.allowed_methods.append(GameRoot.OperationMode.ENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.DARK_INFUSE)
	self.desc="""
Hi! I am glad to see you here practising again!

Emm... About the Chainer and Merger you remember? We've made progress, but the top one mage Einstein Nekidora has outran us again.
Seems he has created a [jit]Universal Potion Brewer[] which is said to be able replace the Chainer, the Merger and more! Even a student like you can create potions that are never seen before!
*Sigh...*

Don't mind me. Just do your exercise.
"""
