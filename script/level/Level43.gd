extends Level
class_name Level43

var a := 'stone'
var b := 'iron'
var c := 'gold'
func on_initial() -> Array[Item]:
	return [
		Item.t(Item.u(a),Item.t2(b,c))
	]

func on_restock() -> Array[Item]:
	return []

func _init():
	self.name="UPB Squared"
	self.level_no="5-3"
	self.win=Item.t(Item.t2(a,b),Item.t2(a,c))
	self.allowed_methods.append(GameRoot.OperationMode.TAUTOLOGIZE)
	self.import_upb()
	self.desc="""
When you are inside a potion brewing process, you might suddenly realize: Emm... I need a new type of potion to proceed!
Fret not, because the UPB is smart enough to support ~starting a new brewing process during one~!
You do not need to end the current process to start a new one. Instead, just use the "start UPB" as normal.
When your next brewing process is finished, the system will automatically return to the current brewing process, with your new potion!

You might have noticed that if you are in a potion brewing process, the panel says "Layer 1".
If you are in a sub-process during a potion brewing process, the panel will say "Layer 2"!
So if you are in a sub-process during a sub-process during a process, the panel will say "Layer 3"!
When you are done with the sub-process, the system will automatically return to the previous process, and the panel will say "Layer 2" again.
This is really handy!

Update on the balance UPB feature:
In a sub-process you can use the balance UPB to get extra input for the input or the input for the parent process/upper layer process. 
(But remember, only the inputs!)
Just by putting the corresponding mold in the balance UPB, you can get extra input for the current process or the parent process!

Hint for this quest:
Start UPB with "Stone > Iron"(Tautologizer), then start with "Stone" during the brewing process.
Remember that you can [red]Balance UPB[] to get extra input!
"""
