extends Level
class_name Level21

func on_initial() -> Array[Item]:
	return [
		Item.t2("iron","diamond","Luxury 3000"),
		Item.t2("gold","diamond","Luxury 2000"),
		Item.o2("iron","gold","Polaris")
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Introduction to Entanglement"
	self.level_no="3-1"
	self.win=Item.u("diamond")
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.desc="""
Welcome to the second half of Year 2! In this chapter we will be exploring ~Entanglements~!

An ~Entanglement~ is a special combination of two items represented as A|B. Like mixtures, the order of the two items DO matter. 
However, the two items are entangled together, which means you cannot separate them by normal means.
But thanks to the great mage Einstein Nekidora, a [blue]cutting-edge[] equipment called the [wack]Disentangler[] has arrived.
To use the Disentangler, you need a potion A->C and another potion B->C. The machine will magically produces a unified potion (A|B)->C, which can later help you disentangle the A|B.
Be careful when you use the Disentangler, as it is [jit]EXPENSIVE[]!
"""
