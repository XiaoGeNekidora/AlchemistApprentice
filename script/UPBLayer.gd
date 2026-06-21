class_name UPBLayer

var items: Array[Item] = []
## The item, not the mold
var introduced: Item = null

func get_item_dict() -> Dictionary[String,int]:
	var my_dict:Dictionary[String,int]={}
	for i in items:
		var id=i.type_str()
		if id not in my_dict:
			my_dict[id]=1
		else:
			my_dict[id]=my_dict[id]+1
	return my_dict

# Returns lost items
func get_diff(other:UPBLayer) -> Array:
	var lost = []
	var my_dict := self.get_item_dict()
	var other_dict := other.get_item_dict()
	var reverse_lookup = {}
	
	for item in items:
		reverse_lookup[item.type_str()]=item
	for item in other.items:
		reverse_lookup[item.type_str()]=item
	
	for item in other_dict:
		var my_amount:int = my_dict.get(item,0)
		var their_amount:int = other_dict.get(item,0)
		if their_amount>my_amount:
			for i in range(their_amount-my_amount):
				lost.append(item)
	
	
	lost.erase(other.introduced.clone().set_mold().type_str())
	
	var ans = lost.map(func(x:String): return reverse_lookup.get(x)).filter(func(it:Item): return not it.is_mold)
	return ans
