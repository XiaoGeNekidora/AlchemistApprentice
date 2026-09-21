extends Level
class_name Level45

# Propositions used by this level:
# A = stone, B = iron, C = silver, D = diamond
#
# Replenishable premise:
#   C
#
# Goal:
#   (A -> (B -> (C -> D))) -> ((A -> B) -> (A -> D))
#
# This is the natural-deduction proof of the goal:
#   assume f : A -> B -> C -> D
#   assume g : A -> B
#   assume a : A
#   f(a) : B -> C -> D
#   g(a) : B
#   f(a)(g(a)) : C -> D
#   C is replenished inside the innermost UPB layer
#   f(a)(g(a))(C) : D
# Then the three assumptions are discharged by ending the three UPB layers.

var a := "stone"
var b := "iron"
var c := "silver"
var d := "diamond"

func on_initial() -> Array[Item]:
	# The original Silver is intentionally present before UPB starts. Using it
	# directly makes Silver appear as an extra premise in the brewed potion.
	return [Item.u(c)]

func on_restock() -> Array[Item]:
	# Restocking at the correct time supplies the global premise C without
	# consuming the copy recorded in the current UPB layer.
	return [Item.u(c)]

func _init():
	var atom_a := Item.u(a)
	var atom_b := Item.u(b)
	var atom_c := Item.u(c)
	var atom_d := Item.u(d)

	var f := Item.t(
		atom_a,
		Item.t(atom_b, Item.t(atom_c, atom_d, "Starlight III"), "Starlight II"),
		"Starlight I"
	)
	var g := Item.t(Item.u(a), Item.u(b), "Spark")

	self.name = "The Final Formula"
	self.level_no = "5-5"
	self.win = Item.t(
		f,
		Item.t(g, Item.t(Item.u(a), Item.u(d), "Completed Formula"), "Second Assumption"),
		"First Assumption"
	)

	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.import_upb()

	self.desc = """
This is the final exam of Year 4 and your last lesson on the Universal Potion Brewer.

The only item on the desk is Silver, yet the target asks for a potion whose
ingredients are themselves potions. No suitable molds are supplied directly.
Remember that the Tautologizer knows the target, and that a mold of a compound
can be broken into molds of its components.

The proof needs the same Stone twice. The innermost UPB layer can balance its
own premise when contraction is required.

Finally, the Silver already on the desk belongs to the outer environment.
If it is consumed after being recorded by UPB, it will become an unwanted
premise of the result. Decide when a fresh Silver should enter the workspace.

[red]Tautology, mold decomposition, nested UPB, balance, and timed restocking
are all part of this exam.[]
"""
