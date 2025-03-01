class_name GridElement

var position : Vector3
var grid_cell : GridCell

var index_in_cell : int

var obj : ActorObject

func _init(actor_obj : ActorObject) -> void:
	obj = actor_obj
	actor_obj.destroyed.connect(_obj_destroyed)

func _obj_destroyed():
	grid_cell.remove_element(self)
