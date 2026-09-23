extends Level
class_name Level52

## C combinator / exchange:
##
##   (A -> (B -> C)) -> (B -> (A -> C))
##
## The proof is intentionally proposition-only: the outer UPB layer records
## the function being exchanged, while the two inner layers swap the order in
## which its arguments are supplied.

var a := "stone"
var b := "iron"
var c := "gold"

func on_initial() -> Array[Item]:
	return []

func on_restock() -> Array[Item]:
	return []

func _init():
	var premise := Item.t(
		Item.u(a),
		Item.t(Item.u(b), Item.u(c), "B to C"),
		"A to B to C"
	)
	var conclusion := Item.t(
		Item.u(b),
		Item.t(Item.u(a), Item.u(c), "A to C"),
		"B to A to C"
	)

	self.name = "Apple then Pen"
	self.level_no = "6-2"
	self.win = Item.t(premise, conclusion, "C Combinator")
	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.import_upb()
	self.desc = """
If you put a pen in the box, then put an apple in the box, you have "an apple and a pen" in the box.
But if you put the apple first, then put the pen in the box, you still have "an apple and a pen" in the box!
Makes sense right?
"""
