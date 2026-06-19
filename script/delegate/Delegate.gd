class_name Delegate

func arg_count() -> int:
	return 2

func transform_button_name() -> String:
	return "???"

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	return [0,"TODO"]
	
func craft(m:Item, p: Item):
	return 