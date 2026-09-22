extends Level
class_name Level51


var a := "stone"
var b := "iron"
var c := "gold"

func on_initial() -> Array[Item]:
	return []

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name = "Introduction to AETHER"
	self.level_no = "6-1"
	self.win = Item.t(
		Item.u(a),
		Item.t2(b,a),
		"Weird Potion"
	)

	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.import_upb()

	self.desc = """
Welcome to the bonus chapter! In this chapter we will be deep-digging the ~miraculous~ AETHER workflow coined by Einstein Nekidora himself.

What is AETHER? It stands for "Atmospheric Elixir Transmutation via Harnessing Ethereal Resonance". Basically, it is a new way to brew some potions WITHOUT ANYTHING using the UPB!

You may ask, what "kind of potions" can be brewed this way? Well, this is an interesting topic. The answer is: I DONT KNOW!

Very unbelievable right?! Me too! But it's true! Use the tautologizer and try yourself!


"""
