class_name Selection

var selected : ActorObject

signal selection_changed(selected : ActorObject)

func other_selected(other : ActorObject) -> void:
	if selected:
		selected.move.hide()
	
	selected = other
	selected.move.show()
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
