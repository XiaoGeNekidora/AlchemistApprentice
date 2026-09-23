extends Level
class_name Level54

## Destructive dilemma:
##
##   (A -> B) -> ((C -> D) -> ((!B | !D) -> (!A | !C)))
##
## Dark Infusion supplies the two contrapositives. The remaining work is a
## case split over the entanglement of the two negative conclusions.

var a := "stone"
var b := "iron"
var c := "silver"
var d := "gold"

func on_initial() -> Array[Item]:
	return []

func on_restock() -> Array[Item]:
	return []

func _init():
	var first := Item.t(Item.u(a), Item.u(b), "Sacrifice 1")
	var second := Item.t(Item.u(c), Item.u(d), "Sacrifice 2")
	var negative_input := Item.o(Item.n2(b), Item.n2(d), "Reward 1")
	var negative_output := Item.o(Item.n2(a), Item.n2(c), "Reward 2")
	var conclusion := Item.t(negative_input, negative_output, "Reward Linker")
	var from_second := Item.t(second, conclusion, "Ritual")

	self.name = "Demon's Trade"
	self.level_no = "6-4"
	self.win = Item.t(first, from_second, "The Demon's Trade")
	self.allowed_methods.append(GameRoot.OperationMode.DARK_INFUSE)
	self.allowed_methods.append(GameRoot.OperationMode.ENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.import_upb()
	self.desc = """
Have you figured out what kind of potions AETHER can craft?

Maybe are those that are COMMON SENSE?!?!

Just kidding lol.
"""
