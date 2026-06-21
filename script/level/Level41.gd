extends Level
class_name Level41

var a := 'stone'
var b := 'iron'
var c := 'silver'
var d := 'gold'
var e := 'diamond'
func on_initial() -> Array[Item]:
	return [
		Item.t(Item.a(Item.u(a),Item.n2(b)),Item.o(Item.u(d),Item.u(e))),
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="A Great Era"
	self.level_no="5-1"
	self.win=Item.a(Item.u("gold").set_mold(),Item.u("diamond").set_mold())
	self.allowed_methods.append(GameRoot.OperationMode.PACKAGE)
	self.allowed_methods.append(GameRoot.OperationMode.UNPACKAGE)
	self.allowed_methods.append(GameRoot.OperationMode.MOLD)
	self.desc="""
Welcome to the ~brand new course~ for your Year 4! In this year we will be learning the latest progress in alchemy: UPB.

Up to now, you only know how to use potions. But, you don't know how to "create" a new potion from scratch. 
You might think this is a trivial task: "If I have an object A, after some steps I made an object B. I can just pour all the potions used, to create a potion A->B."
This is inaccurate because first, not all potions can be mixed together. Second, you might have used machines like the Dark Infuser, not potions right?

However, the UPB is a revolutionary invention! It just brings your little stupid idea into reality! 
It is capable of recording your steps, and contains a "potionize" module that converts the machine steps you used as potion instances. For example, for a package operation it creates a potion A->(B->(A&B)).
Usually this takes a mage years, but now it can be done automatically!

One greater feature is that you don't even need the starting substance A! Instead, you use a [green]Mold[].
To create the mold, you use the ~Mold Press~. It has two features:
1. If you put a real item in, it creates a mold of that item. The item is NOT consumed.
2. If you put a mold in, it breaks the mold into molds of the components of that item. That is, the two substances in mixture/entanglement, input&output of a potion and the original substance in a corrupted(dark-infused) object.

The mold has a $m added as a prefix in the notation.

It's a lot of new information! For you and for myself as well, as this is a really new concept!
Take your time and we will continue in the next lesson. 
"""
