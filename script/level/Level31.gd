extends Level
class_name Level31

func on_initial() -> Array[Item]:
	return [
		Item.t2("diamond","iron","Poor 3000"),
		Item.n2("iron")
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Dark Magic"
	self.level_no="4-1"
	self.win=Item.n2("diamond")
	self.allowed_methods.append(GameRoot.OperationMode.DARK_INFUSE)
	self.desc="""
[jit2]You've come far...[] Anyway, welcome to Year 3! In this chapter, we will be learning [jit]Dark Magic[].
Dark magic is a very dangerous yet not fully understood subject, as it involves dark matter and corrupted potions that can absorb your soul when touched.
The gate to the dark world is the [red]Dark Infuser[], which is known as the window for trading with [jit]demons[].
To use it, throw a potion A->B in and it will return the overworld variant: (!B)->(!A), which involves dark&corrupted matters: !B and !A.
"What if I throw it in twice?" Well, try it out yourself!
"""
