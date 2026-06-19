extends Level
class_name Level23

func on_initial() -> Array[Item]:
	var a := 'stone'
	var b := 'iron'
	var c := 'silver'
	var d := 'gold'
	var e := 'diamond'
	return [
		Item.t(Item.o(Item.o2(a,b),Item.o2(c,d)),Item.u(e),"Borshch"),
		Item.u(a)
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="The Entangler"
	self.level_no="3-3"
	self.win=Item.u("diamond")
	self.allowed_methods.append(GameRoot.OperationMode.ENTANGLE);
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.desc="""
Today we are excited to announce a new equipment in our magic lab: the ~Entangler~!!
The ~Entangler~ is a magic machine that uses a very interesting way to bypass the laws of traditional magic!
It needs a potion whose input is an Entanglement A|B to start. It will scan the input and analyze the two parts automatically.
Then it will create two potions for creating the entanglement: A->(A|B) and B->(A|B)! 
Wow, this is surely ~magic~!
"""
