extends Level
class_name Level42

var a := 'stone'
var b := 'iron'
var c := 'silver'
var d := 'gold'
var e := 'diamond'
func on_initial() -> Array[Item]:
	return [
		Item.t2(a,c),
		Item.t2(c,e),
#		Item.u(a).set_mold()
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Introduction to UPB"
	self.level_no="5-2"
	self.win=Item.t2("stone","diamond")
	self.import_upb()
	self.desc="""
Let's learn how to use the UPB! This is a typical UPB workflow for creating a potion A->B:
1. Create a mold of A
2. Use the ~Start UPB~ operation with the mold of A.
3. The UPB will start, and [red]replace your mold of A with a real A[].
4. Do whatever you want with this real A until you get a B. You can check the potion to be generated on the UPB Display Screen.
5. Use the ~End UPB~ operation with the B.
6. Your workspace will be reverted to the moment you started the UPB, but with the created potion A->B.
Why revert? Because that A isn't real and everything you created with that A isn't real either! They are replica by UPB.

Now let's try to use the UPB as a Chainer!
"""
