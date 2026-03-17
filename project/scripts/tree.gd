extends Tree

var root

var dragged_node
var dragged_target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _get_drag_data(_at_position: Vector2) -> Variant:
	var items := []
	var next: TreeItem = get_next_selected(null)
	var v := VBoxContainer.new()
	while next:
		items.append(next)
		var l := Label.new()
		l.text = next.get_text(0)
		v.add_child(l)
		next = get_next_selected(next)
	set_drag_preview(v)
	Console.print("initial item", items[0].get_text(0))
	# items is an array of selected items that are being dragged
	return items

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# method to test if data from a control's _get_drag_data() can be 
	# dropped at at_position. at_position is local to this control.
	drop_mode_flags = Tree.DROP_MODE_INBETWEEN
	var drop_section := get_drop_section_at_position(at_position)
	if drop_section == -100:
		return false
	var item := get_item_at_position(at_position)
	# Console.print("drop target", item.get_text(0))
	# Console.print("dragging", data[0].get_text(0))
	if item in data:
		return false
	
	dragged_node = root.current_database.get_resource_by_id(data[0].get_text(0))
	dragged_target = root.current_database.get_resource_by_id(item.get_text(0))
	
	if not dragged_node or not dragged_target:
		return false
	
	if not dragged_node.get("type") or not dragged_target.get("type"):
		return false
	
	var type_dragging = dragged_node.type
	var type_target = dragged_target.type
	
	if type_target != type_dragging:
		return false
	
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var drop_section := get_drop_section_at_position(at_position)
	var other_item := get_item_at_position(at_position)
	var mode
	#var sprite_groups := []
	#for item in data:
		#sprite_groups.append(item.get_meta("sprite_group"))
	for i in data.size():
		var item := data[i] as TreeItem
		Console.print(item.get_text(0))
		if drop_section == -1:
			item.move_before(other_item)
			mode = "before"
		elif drop_section == 1:
			mode = "after"
			if i == 0:
				item.move_after(other_item)
			else:
				item.move_after(data[i - 1])
	
	Console.print("node moved:", dragged_node.id)
	Console.print("moved", mode, dragged_target.id)
	root.current_database.move_item(dragged_node, dragged_target, mode)
