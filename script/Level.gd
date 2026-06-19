
class_name Level

var name:="Test Level"
var level_no:="0"
var win:=Item.u("stone")
var desc:="This is a test level"
var allowed_methods := [GameRoot.OperationMode.TRANSFORM]
var has_next_level := true

func import_packages():
	allowed_methods.append(GameRoot.OperationMode.PACKAGE)
	allowed_methods.append(GameRoot.OperationMode.UNPACKAGE)

func on_initial() -> Array[Item]:
	return []

func on_restock() -> Array[Item]:
	return []
