class_name OperationDelegate

## The Item display prefab
static var id: PackedScene
static var root: GameRoot
static var in_particle: CPUParticles2D
static var out_particle: CPUParticles2D
static var item_here: Marker2D
static var tooltip: TooltipWidget

func get_operation_name() -> String:
	return "???"

func arg_count() -> int:
	return 2

func transform_button_name() -> String:
	return "???"

func hint_text() -> String:
	return "???"

## Returns [0,hint] if success, [1, err_msg] if fail
func update(m:Item, p: Item) -> Array:
	return [0,"TODO"]
	
func craft():
	return 

## Calls root
func on_potion_update():
	root.on_potion_update()

## Calls root
func win_game():
	root.win_game()

## Calls root
func put_down(item):
	root.put_down(item)
	
## Calls root
func get_tree() -> SceneTree:
	return root.get_tree()
