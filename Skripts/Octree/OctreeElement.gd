class_name OctreeElement

var index : int
var successor : OctreeElement
var predecessor : OctreeElement
var octant : Octant

var position : Vector3
var active : bool
var obj : Actor

func update_position():
	if !obj:
		return
	position = obj.position
