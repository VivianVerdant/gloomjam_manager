extends Tree

var root

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
	root._print("initial item", items[0].get_text(0))
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
	root._print("drop target", item.get_text(0))
	# root._print("dragging", data[0].get_text(0))
	if item in data:
		return false
	
	var dragging = root.current_database.get_resource_by_id(data[0].get_text(0))
	var target = root.current_database.get_resource_by_id(item.get_text(0))
	
	if not dragging or not target:
		return false
	
	if not dragging.get("type") or not target.get("type"):
		return false
	
	var type_dragging = dragging.type
	var type_target = target.type
	
	if type_target != type_dragging:
		return false
	
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var drop_section := get_drop_section_at_position(at_position)
	var other_item := get_item_at_position(at_position)
	var sprite_groups := []
	for item in data:
		sprite_groups.append(item.get_meta("sprite_group"))
	for i in data.size():
		var item := data[i] as TreeItem
		if drop_section == -1:
			item.move_before(other_item)
		elif drop_section == 1:
			if i == 0:
				item.move_after(other_item)
			else:
				item.move_after(data[i - 1])
