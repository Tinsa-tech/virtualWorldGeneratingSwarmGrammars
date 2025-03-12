class_name Actor

var energy : float
var id : int
var back_reference : Actor
var type : String
var actor_position : Vector3

func equals(other : Actor) -> bool:
	if other.type == self.type:
		return true
	return false

func take_values(template : ActorTemplate):
	type = template.type
