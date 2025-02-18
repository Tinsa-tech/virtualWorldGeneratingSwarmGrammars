class_name Actor

extends Node3D

var energy : float
var id : int
var back_reference : Actor
var type : String

func equals(other : Actor) -> bool:
	if other.type == self.type:
		return true
	return false

func take_values(template : ActorTemplate):
	type = template.type
