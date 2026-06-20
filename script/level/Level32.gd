extends Level
class_name Level32

func on_initial() -> Array[Item]:
	return [
		Item.t2("iron","gold"),
		Item.n2("gold"),
		Item.t(Item.n2("iron"),Item.u("diamond")),
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Dark Magic II"
	self.level_no="4-2"
	self.win=Item.u("diamond")
	self.allowed_methods.append(GameRoot.OperationMode.DARK_INFUSE)
	self.desc="""
Hi! Nothing new today! You can do some self-exercise. :)

In the meantime, I would like to share with you a little story about the world before these magical automata like Packager are invented.
In the past, we, the great mages, can still make mixtures without the machine. However, we have to do it manually. These are called packager potions: A->(B->(A&B)).
For different components A and B, the recipe and procedure are all different. There used to be whole books on this!
But now, the packager is here. No matter what A and B are, you can just throw them in and get the mixture. So convenient! But also, a little bit sad, isn't it?...

"""
