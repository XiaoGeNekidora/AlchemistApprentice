extends Level
class_name Level11

func on_initial() -> Array[Item]:
	return [
		Item.a2("iron","silver","Is"),
		Item.a2("silver","gold","Sg"),
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="Introduction to Mixture"
	self.level_no="2-1"
	self.win=Item.a2("iron","gold","Ig")
	self.import_packages()
	self.desc="""Welcome to the second year of your alchemy lessons! Luckily you did not blow yourself up in the first year.
In this year we will be learning two new types of matter: ~Mixture~ and ~Entanglement~.
In this chapter, you will be learning ~Mixture~ first and in the next chapter you will be taught what ~Entanglement~ is.

A ~Mixture~ is an ORDERED combination of two items represented as A&B. That means the order of the two items matters. For example, the ~Mixture~ of iron and gold is different from the ~Mixture~ of gold and iron. 
You might have also noticed the two new operators: [green]Package[] and [red]Unpackage[]! 
Please, [wack]click[] to switch between them. Try to understand what they do!
"""
