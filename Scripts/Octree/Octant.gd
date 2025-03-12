class_name Octant

var center : Vector3
var extend : float # length of the sides / 2

var parent : Octant
var index_in_parent : int
var previous : Octant
var next : Octant
var first_child_with_element : Octant
var last_child_with_element : Octant

var children : Array[Octant]

var is_leaf : bool = true

## if this octant has the element that the parents start_index is on
var has_first : bool = false
## if this octant has the element that the parents end_index is on
var has_last : bool = false
var start_index : int = -1
var end_index : int = -1

var nr_of_elements : int = 0

func _init(center : Vector3, extend : float):
	self.center = center
	self.extend = extend

func is_point_in_octant(point : Vector3) -> bool:
	var diff = point - center
	diff = diff.abs()
	var max_v = max(diff.x, diff.y, diff.z)
	return max_v <= extend

func set_start_index(new_index : int):
	start_index = new_index
	if !parent:
		return
	if has_first:
		parent.set_start_index(new_index)
		return
	if index_in_parent < parent.first_child_with_element.index_in_parent:
		has_first = true
		parent.first_child_with_element.has_first = true
		parent.first_child_with_element = self
		parent.set_start_index(new_index)
		
func set_end_index(new_index : int):
	end_index = new_index
	if !parent:
		return
	if has_last:
		parent.set_end_index(new_index)
		return
	if index_in_parent > parent.last_child_with_element.index_in_parent:
		has_last = true
		parent.last_child_with_element.has_last = false
		parent.last_child_with_element = self
		parent.set_end_index(new_index)

func remove_element():
	nr_of_elements -= 1
	if !parent:
		if nr_of_elements > 0:
			return
		if children.size() > 0:
			previous = children[0].previous
			next = children[7].next
			previous.next = self
			next.previous = self
			first_child_with_element = null
			last_child_with_element = null
			for child in children:
				child.next = null
				child.previous = null
			children.clear()
		return
	parent.remove_element()
	if nr_of_elements > 0:
		return
	if children.size() > 0:
		previous = children[0].previous
		next = children[7].next
		previous.next = self
		next.previous = self
		first_child_with_element = null
		last_child_with_element = null
		for child in children:
			child.next = null
			child.previous = null
		children.clear()
	if has_first:
		has_first = false
		parent.first_child_with_element = null
		parent.search_first()
	elif has_last:
		has_last = false
		parent.last_child_with_element = null
		parent.search_last()

func add_element():
	nr_of_elements += 1
	if !parent:
		return
	if nr_of_elements == 1:
		parent.search_first()
		parent.search_last()
	else:
		parent.search_last()
	parent.add_element()

func search_first():
	if nr_of_elements == 0:
		return
	if first_child_with_element:
		first_child_with_element.has_first = false
		first_child_with_element = null
	for child in children:
		if child.nr_of_elements > 0:
			child.has_first = true
			first_child_with_element = child
			set_start_index(child.start_index)

func search_last():
	if nr_of_elements == 0:
		return
	if last_child_with_element:
		last_child_with_element.has_last = false
		last_child_with_element = null
	for i in range(7, -1, -1):
		if children[i].nr_of_elements > 0:
			var child = children[i]
			child.has_last = true
			last_child_with_element = child
			set_end_index(child.end_index)
