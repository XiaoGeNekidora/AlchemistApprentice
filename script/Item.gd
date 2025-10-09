class_name Item

enum ItemType{
	UNIT=0,
	TRANSFORM=1,
	AND=2,
	OR=3
}

var type: ItemType

var name: String

var left: Item
## If UNIT, this could be undefined
var right: Item
## 0 means no tag
var tag: int

static var hash_name_candidate=["Transubstantiation",
"Perpetuitas",
"Aequimutation",
"Omnigenesis",
"Coruscation",
"Wyrdweave",
"Unwending",
]

## Generate a fake hash name based on left and right
func hash_name() -> String:
	var hsh=(type_str().hash())%len(hash_name_candidate)
	return hash_name_candidate[hsh]

## Return a hash of the type str
func hash() -> int:
	return type_str().hash()

func type_str() -> String:
	if type==ItemType.UNIT:
		return name
	elif type==ItemType.TRANSFORM:
		return "( %s -> %s )"%[left.type_str(),right.type_str()]
	elif type==ItemType.AND:
		return "( %s & %s )"%[left.type_str(),right.type_str()]
	elif type==ItemType.OR:
		return "( %s | %s )"%[left.type_str(),right.type_str()]
	return "?"

static func u(name: String) -> Item:
	return Item.new(ItemType.UNIT, name, null, null)

static func t2(left: String, right: String, name: String = "") -> Item:
	return Item.new(ItemType.TRANSFORM,name,Item.u(left),Item.u(right))

static func t(left: Item, right: Item, name: String = "")->Item:
	return Item.new(ItemType.TRANSFORM,name,left,right)

func equals(o: Item) -> bool:
	return o.type_str()==self.type_str()

func _init(type: ItemType,  name: String, left: Item, right: Item , tag: int=0):
	self.type=type
	self.name=name
	self.left=left
	self.right=right
	self.tag=tag
