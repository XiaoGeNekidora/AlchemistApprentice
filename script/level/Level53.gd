extends Level
class_name Level53

## Currying (one direction):
##
##   ((A & B) -> C) -> (A -> (B -> C))
##
## The reverse direction is deliberately omitted. This keeps the level about
## introducing assumptions and packaging them, rather than making it a second
## full-sized exam hidden inside the first one.

var a := "stone"
var b := "iron"
var c := "silver"

func on_initial() -> Array[Item]:
	return []

func on_restock() -> Array[Item]:
	return []

func _init():
	var pair := Item.a2(a, b, "A and B")
	var premise := Item.t(pair, Item.u(c), "Pair to C")
	var conclusion := Item.t(
		Item.u(a),
		Item.t(Item.u(b), Item.u(c), "B to C"),
		"A to B to C"
	)

	self.name = "Apple and Pen"
	self.level_no = "6-3"
	self.win = Item.t(premise, conclusion, "Currying")
	self.import_packages()
	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.import_upb()
	self.desc = """
If you put a pen in the box, then put an apple in the box, you have "an apple and a pen" in the box.
But if you put the apple AND the pen together, you still have "an apple and a pen" in the box!
Makes sense right?
"""
