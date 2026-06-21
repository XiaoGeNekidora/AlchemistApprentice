extends OperationDelegate
class_name TemplateDelegate

func can_use_mold() -> bool:
	return false
	
func get_operation_name() -> String:
	return "FILL OPERATION NAME HERE"

func arg_count() -> int:
	return 1

func transform_button_name() -> String:
	return "DO SOMETHING!!"

func hint_text() -> String:
	return "???"

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	return [1, "To be implemented"]
	
func craft():
	pass