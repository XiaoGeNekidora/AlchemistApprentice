class_name Item

enum ItemType{
	UNIT=0,
	TRANSFORM=1,
	AND=2,
	OR=3
}

var type: ItemType

var name: String

## Represents the input for catalysts. the first component in AND/OR. If UNIT, this could be undefined
var left: Item
## Represents the output for catalysts. the second component in AND/OR. If UNIT, this could be undefined
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

## Create a unit item with given name
static func u(name: String) -> Item:
	return Item.new(ItemType.UNIT, name, null, null)

## Create a transform item with name
static func t2(left: String, right: String, name: String = "") -> Item:
	return Item.new(ItemType.TRANSFORM,name,Item.u(left),Item.u(right))

## Create a transform item
static func t(left: Item, right: Item, name: String = "")->Item:
	return Item.new(ItemType.TRANSFORM,name,left,right)

## Create a mixture transformer  (a&b->(a&b))
static func ta(a: Item, b: Item, name: String = "")->Item:
	return Item.t(a,Item.t(b,Item.a(a,b,name),name.capitalize()+" Mixer B"),name.capitalize()+" Mixer A")

## Create a mixture transformer by name (a&b->(a&b))
static func ta2(a: String, b: String, name: String = "")->Item:
	return Item.t(Item.u(a),Item.t(Item.u(b),Item.a2(a,b,name),name.capitalize()+" Mixer B"),name.capitalize()+" Mixer A")

## Create a mixture
static func a(left: Item, right: Item, name: String = "") -> Item:
	return Item.new(ItemType.AND,name,left,right)

## Create a mixture by name
static func a2(left: String, right: String, name: String = "") -> Item:
	return Item.new(ItemType.AND,name,Item.u(left),Item.u(right))

func equals(o: Item) -> bool:
	return o.type_str()==self.type_str()

func _init(type: ItemType,  name: String, left: Item, right: Item , tag: int=0):
	self.type=type
	self.name=name
	self.left=left
	self.right=right
	self.tag=tag
