class_name Selection

var selected : ActorObject

signal selection_changed(selected : ActorObject)
signal moved(new_pos : Vector3)

func other_selected(other : ActorObject) -> void:
	if selected and is_instance_valid(selected):
		selected.move.hide()
		if selected.moved.is_connected(selection_moved):
			selected.moved.disconnect(selection_moved)
	
	selected = other
	if selected.editable:
		selected.move.show()
		selected.moved.connect(selection_moved)
	selection_changed.emit(selected)

func move_x(new_x : float):
	selected.position = Vector3(new_x, selected.position.y, selected.position.z)
	selected.actor.actor_position = selected.position

func move_y(new_y : float):
	selected.position = Vector3(selected.position.x, new_y, selected.position.z)
	selected.actor.actor_position = selected.position

func move_z(new_z : float):
	selected.position = Vector3(selected.position.x, selected.position.y, new_z)
	selected.actor.actor_position = selected.position

func move(new_pos : Vector3):
	selected.position = new_pos
	selected.actor.actor_position = new_pos

func selection_moved():
	var new_pos = selected.actor.actor_position
	moved.emit(new_pos)
