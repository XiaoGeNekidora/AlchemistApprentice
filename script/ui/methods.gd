extends HBoxContainer

func set_modes(mode: Array):
	var idx:=0
	for child in get_children():
		if idx in mode:
			child.show()
		else:
			child.hide()
		idx+=1
