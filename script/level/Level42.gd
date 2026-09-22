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
5. If you ever require multiple instances of A, use the ~Balance UPB~ feature *with the corresponding mold*. Don't worry, even if your process requires 1,000 A to produce 1 unit of B, you will still get a potion A->B instead of 1000A->B.
6. Use the ~End UPB~ operation with the B.
7. Your workspace will be reverted to the moment you started the UPB, but with the created potion A->B.
Why revert? Because that A isn't real and everything you created with that A isn't real either! They are phantom replicas by UPB.

Now let's try to use the UPB as a Chainer!
"""
