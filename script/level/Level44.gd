extends Level
class_name Level44

var a := 'stone'
var b := 'iron'
var c := 'gold'
var d := 'diamond'
func on_initial() -> Array[Item]:
	return [
		Item.u(a),
		Item.u(b),
		Item.u(c),
		Item.t(Item.u(a),Item.t(Item.u(b),Item.t(Item.u(c),Item.u(d))))
	]

func on_restock() -> Array[Item]:
	return [Item.u(b),Item.u(c)]

func _init():
	self.name="Outer Environment"
	self.level_no="5-3"
	self.win=Item.t2(a,d)
	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.import_upb()
	self.desc="""
You can get infinitely many input in the UPB. However, if UPB detects a usage of items in outer environment, it will add that item to the potion recipe as well.
For example, if you want to create a potion from A to C but you used substance B in the process, the UPB will not output your expected potion A->C but A->(B->C).
If there is a way to circumvent this... (Hey! ~Restock~ , I am talking about you!)
"""
