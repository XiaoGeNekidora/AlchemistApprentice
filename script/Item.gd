class_name Item

enum ItemType{
	UNIT=0,
	TRANSFORM=1,
	AND=2,
	OR=3
}

var type: ItemType
var left: String
## If UNIT, this could be undefined
var right: String
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
	var hsh=(left.hash()*97+right.hash())%len(hash_name_candidate)
	return hash_name_candidate[hsh]

func type_str() -> String:
	if type==ItemType.UNIT:
		return left
	elif type==ItemType.TRANSFORM:
		return "(%s -> %s)"%[left,right]
	elif type==ItemType.AND:
		return "(%s & %s)"%[left,right]
	elif type==ItemType.OR:
		return "(%s | %s)"%[left,right]
	return "?"

static func from_str(s: String) -> Item:
	if s[0]!="(":
		return Item.new(ItemType.UNIT,s)
		
	var ly=0
	var left=null
	var right=null
	
	for i in range(len(s)):
		var c=s[i]
		if c=="(":
			ly+=1
		elif c==")":
			ly-=1
		if ly==0:
			left=s.substr(0,i+1)
			break
	for i in range(len(s)-1,0,-1):
		var c=s[i]
		if c==")":
			ly+=1
		elif c=="(":
			ly-=1
		if ly==0:
			right=s.substr(i)
			break
	var op=s.substr(len(left),len(s)-len(left)-len(right)).strip_edges()
	
	if op=="->":
		return Item.new(ItemType.TRANSFORM,left,right)
	elif op=="&":
		return Item.new(ItemType.AND,left,right)
	elif op=="|":
		return Item.new(ItemType.OR,left,right)
	else:
		return null

func _init(type: ItemType, left: String, right: String = "", tag: int=0):
	self.type=type
	self.left=left
	self.right=right
	self.tag=tag
