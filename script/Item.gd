class_name Item

enum ItemType{
	UNIT=0,
	TRANSFORM=1,
	AND=2,
	OR=3,
	NOT=4,
}

var is_mold: bool = false

var type: ItemType

var name: String

## Represents the input for catalysts. the first component in AND/OR. Or the component in NOT. If UNIT, this could be undefined
var left: Item
## Represents the output for catalysts. the second component in AND/OR. If UNIT/NOT, this could be undefined
var right: Item
## 0 means no tag
var tag: int

## Return a hash of the type str
func hash() -> int:
	return type_str().hash()

func type_str() -> String:
	var ans := ""
	if type==ItemType.UNIT:
		ans=name
	elif type==ItemType.TRANSFORM:
		ans="( %s -> %s )"%[left.type_str(),right.type_str()]
	elif type==ItemType.AND:
		ans="( %s & %s )"%[left.type_str(),right.type_str()]
	elif type==ItemType.OR:
		ans="( %s | %s )"%[left.type_str(),right.type_str()]
	elif type==ItemType.NOT:
		ans="! %s"%[left.type_str()]
	else:
		return "?"
	if is_mold:
		ans="$M "+ans
	
	return ans

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

## Create an entanglement
static func o(left: Item, right: Item, name: String = "") -> Item:
	return Item.new(ItemType.OR,name,left,right)

## Create an entanglement by name
static func o2(left: String, right: String, name: String = "") -> Item:
	return Item.new(ItemType.OR,name,Item.u(left),Item.u(right))

## Generate a potion (A->B)->(B->C)->(A->C)
static func chain(a: Item, b: Item, c: Item, name: String = "") -> Item:
	return Item.t(
		Item.t(a,b),
		Item.t(
			Item.t(b,c),
			Item.t(a,c,name),
			name+" Chainer B"
		),
		name+" Chainer A"
	)

static func n(a: Item) -> Item:
	return Item.new(ItemType.NOT,a.name,a,null)

static func n2(name:String) -> Item:
	var x = Item.u(name)
	return Item.new(ItemType.NOT, x.name, x, null)

func set_mold() -> Item:
	is_mold = true
	return self

func equals(o: Item) -> bool:
	return o.type_str()==self.type_str()

func _init(type: ItemType,  name: String, left: Item, right: Item , tag: int=0):
	self.type=type
	self.name=name
	self.left=left
	self.right=right
	self.tag=tag

func clone() -> Item:
	var i:=Item.new(type, name, left, right, tag)
	i.is_mold=is_mold
	return i