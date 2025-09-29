extends Level
class_name Level1

func on_initial() -> Array[Item]:
	return [
		Item.new(Item.ItemType.UNIT,"stone"),
		Item.new(Item.ItemType.TRANSFORM,"stone","gold")
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.win=Item.new(Item.ItemType.UNIT, "gold")
	self.desc="""
Welcome to the ~School of Alchemy~! Here you will be mastering the [sin]ART[] of transformation.
Today is your first lesson? Do not worry! We have prepared your starter kit for you.
Just [wack]click[] that bag over there!

Transformation is just about applying the right catalyst on the right base material. Easy, right?
[wack]Click[] the stone to put it as a base material, then [wack]click[] the catalyst.
You should be able to see the [sin]Transform Button[] sitting there already! Wait what? Just [wack]click[] it!!

Target: Get [white]Gold[]
"""
