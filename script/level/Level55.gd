extends Level
class_name Level55

## Distributivity, both directions:
##
##   (A & (B | C)) <-> ((A & B) | (A & C))
##
## The game has no primitive biconditional, so the target is a mixture of the
## two implications. This is the chapter's final proof and intentionally
## requires Package, Unpackage, Entangle, Disentangle and nested UPB layers.

var a := "stone"
var b := "iron"
var c := "silver"

func on_initial() -> Array[Item]:
	return []

func on_restock() -> Array[Item]:
	return []

func _init():
	var left_input := Item.a(Item.u(a), Item.o2(b, c, "B or C"), "A and (B or C)")
	var right_output := Item.o(
		Item.a2(a, b, "A and B"),
		Item.a2(a, c, "A and C"),
		"Distributed Result"
	)
	var forward := Item.t(left_input, right_output, "Distribute Forward")

	var reverse_input := Item.o(
		Item.a2(a, b, "A and B"),
		Item.a2(a, c, "A and C"),
		"Distributed Result"
	)
	var reverse_output := Item.a(
		Item.u(a),
		Item.o2(b, c, "B or C"),
		"A and (B or C)"
	)
	var backward := Item.t(reverse_input, reverse_output, "Distribute Backward")

	self.name = "The Distributive Seal"
	self.level_no = "6-5"
	self.win = Item.a(forward, backward, "Distributivity")
	self.allowed_methods.append(GameRoot.OperationMode.ENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.DISENTANGLE)
	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.import_packages()
	self.import_upb()
	self.desc = """
This might be one of the most challenging tasks in your school life! But it will be the last!
Hope you have enjoyed the journey of alchemy and hope to see you soon!
... Actually we *could* also throw in dark matters but then your operation list will be too long!
Try your best!
"""
