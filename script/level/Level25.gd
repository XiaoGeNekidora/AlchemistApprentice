extends Level
class_name Level25

func on_initial() -> Array[Item]:
	var a := 'stone'
	var b := 'iron'
	var c := 'silver'
	var d := 'gold'
	var e := 'diamond'
	return [
		Item.t(Item.o2(a,b),Item.u(e),"Dimensional Miner I"),
		Item.t(Item.o2(a,b),Item.u(e),"Dimensional Miner I"),
		Item.t(Item.o2(c,d),Item.u(e),"Dimensional Miner II"),
		Item.t(Item.o2(c,d),Item.u(e),"Dimensional Miner II"),
		Item.o2(a,c,"Ice and Fire"),
		Item.chain(Item.u(a),Item.o2(a,b),Item.u(e),"Pegasus"),
		Item.chain(Item.u(c),Item.o2(c,d),Item.u(e),"Unicorn")
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Entanglement Exam"
	self.level_no="3-5"
	self.win=Item.u("diamond")
	self.allowed_methods.append(GameRoot.OperationMode.ENTANGLE);
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.desc="""
This is the exam for Chapter 3. Try your best!

By the way, have you noticed the "Chainer" and "Merger" in the initial items? 
They are actually a prototype of the new "Chainer" and "Merger" machine coming soon!
We sure are advancing a lot, aren't we? :D
"""
