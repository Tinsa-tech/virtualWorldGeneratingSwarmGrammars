class_name Octree 

var bucket_size : int

var elements : Array[OctreeElement]

var root : Octant

func _init(bucket_size : int, extend_first_octant : float) -> void:
	root = Octant.new(Vector3.ZERO, extend_first_octant)
	self.bucket_size = bucket_size

func update_positions():
	for element in elements:
		element.update_position()
		var old_octant = element.octant
		if !old_octant:
			continue
		if old_octant.is_point_in_octant(element.position):
			continue
		
		if element.predecessor:
			element.predecessor.successor = element.successor
			element.successor.predecessor = element.predecessor
		if old_octant.start_index == element.index:
			if old_octant.nr_of_elements > 1:
				old_octant.set_start_index(element.successor.index)
			old_octant.remove_element()
		elif old_octant.end_index == element.index:
			if old_octant.nr_of_elements > 1:
				old_octant.set_end_index(element.predecessor.index)
			old_octant.remove_element()
		else:
			old_octant.remove_element()
		
		add_element(element)

func add_element(element : OctreeElement):
	elements.append(element)
	element.index = elements.size() - 1
	
	var look_at = root
	var point = element.position
	var finished = false
	while !finished:
		## point is outside of octree
		if !look_at.is_point_in_octant(point):
			finished = true
			break
		## if octant we are looking at is not a leaf we need to go deeper
		if !look_at.is_leaf:
			for child in look_at.children:
				if child.is_point_in_octant(point):
					look_at = child
					break
			continue
		## if the number of elements in the octant are less than the bucket size
		## or if the extend of the octant is too small
		## add the element to the octant
		if look_at.nr_of_elements + 1 <= bucket_size or look_at.extend <= 1:
			if look_at.nr_of_elements == 0:
				look_at.set_start_index(element.index)
				look_at.set_end_index(element.index)
				var previous_index = get_previous_index(look_at)
				if previous_index == -1:
					var next_index = get_next_index(look_at)
					if next_index != -1:
						var next = elements[next_index]
						element.successor = next
						element.octant = look_at
						next.predecessor = element
						finished = true
				else:
					var prev = elements[previous_index]
					element.predecessor = prev
					element.successor = prev.successor
					element.octant = look_at
					prev.successor = element
					finished = true
				look_at.add_element()
				break
			else:
				var end_element = elements[look_at.end_index]
				element.successor = end_element.successor
				end_element.successor = element
				element.octant = look_at
				look_at.set_end_index(element.index)
				look_at.add_element()
				finished = true
				break
		else:
			split_octant(look_at)
			for child in look_at.children:
				if child.is_point_in_octant(point):
					look_at = child
					break

func get_previous_index(octant : Octant) -> int:
	if octant.nr_of_elements == 0:
		var look_at = octant
		while true:
			if !look_at.previous:
				break
			var previous = look_at.previous
			if previous.nr_of_elements == 0:
				look_at = previous
			else:
				return previous.end_index
		return -1
	else:
		return octant.end_index

func get_next_index(octant : Octant) -> int:
	var look_at = octant
	while true:
		if !look_at.next:
			break
		var next = look_at.next
		if next.nr_of_elements == 0:
			look_at = next
		else:
			return next.start_index
	return -1

func split_octant(octant : Octant):
	var offset = octant.extend / 2
	print("split octant, new extend: " + str(offset))
	## this should be in morton order
	## 000, 001, 010, 011, 100, 101, 110, 111
	## 0 = -offset, 1 = offset
	var child0 = Octant.new(octant.center + Vector3(-offset, -offset, -offset), offset)
	var child1 = Octant.new(octant.center + Vector3(-offset, -offset, offset), offset)
	var child2 = Octant.new(octant.center + Vector3(-offset, offset, -offset), offset)
	var child3 = Octant.new(octant.center + Vector3(-offset, offset, offset), offset)
	var child4 = Octant.new(octant.center + Vector3(offset, -offset, -offset), offset)
	var child5 = Octant.new(octant.center + Vector3(offset, -offset, offset), offset)
	var child6 = Octant.new(octant.center + Vector3(offset, offset, -offset), offset)
	var child7 = Octant.new(octant.center + Vector3(offset, offset, offset), offset)
	
	child0.parent = octant
	octant.children.append(child0)
	child0.index_in_parent = 0
	child1.parent = octant
	octant.children.append(child1)
	child1.index_in_parent = 1
	child2.parent = octant
	octant.children.append(child2)
	child2.index_in_parent = 2
	child3.parent = octant
	octant.children.append(child3)
	child3.index_in_parent = 3
	child4.parent = octant
	octant.children.append(child4)
	child4.index_in_parent = 4
	child5.parent = octant
	octant.children.append(child5)
	child5.index_in_parent = 5
	child6.parent = octant
	octant.children.append(child6)
	child6.index_in_parent = 6
	child7.parent = octant
	octant.children.append(child7)
	child7.index_in_parent = 7
	
	child0.previous = octant.previous
	child0.next = child1
	child1.previous = child0
	child1.next = child2
	child2.previous = child1
	child2.next = child3
	child3.previous = child2
	child3.next = child4
	child4.previous = child3
	child4.next = child5
	child5.previous = child4
	child5.next = child6
	child6.previous = child5
	child6.next = child7
	child7.previous = child6
	child7.next = octant.next
	
	octant.is_leaf = false
	
	var element = elements[octant.start_index]
	
	for i in range(octant.nr_of_elements):
		for child in octant.children:
			if child.is_point_in_octant(element.position):
				if child.nr_of_elements == 0:
					child.start_index = element.index
					child.end_index = element.index
				else:
					var end = elements[child.end_index]
					element.successor = end.successor
					element.predecessor = end
					end.successor = element
					child.end_index = element.index
				element.octant = child
				child.nr_of_elements += 1
				break
		element = element.successor
	
	for child in octant.children:
		var iip = child.index_in_parent
		if iip == 0:
			var previous_index = get_previous_index(child)
			if previous_index != -1:
				elements[previous_index].successor = elements[child.start_index]
			continue
		if iip == 7:
			var next_index = get_next_index(child)
			if next_index != -1:
				elements[child.end_index].successor = elements[next_index]
			break
		
		elements[child.end_index].successor = elements[octant.children[iip + 1].start_index]
		elements[octant.children[iip + 1].start_index].predecessor = elements[child.end_index]
	
	octant.search_first()
	octant.search_last()

func find_octant(element : OctreeElement) -> Octant:
	var stack : Array[Octant] = [root]
	while !stack.is_empty():
		var octant : Octant = stack.pop_front()
		var current = elements[octant.start_index]
		for i in range(octant.nr_of_elements - 1):
			if current.index == element.index:
				if octant.is_leaf:
					return octant
				stack.append_array(octant.children)
			current = current.successor
	return 
	
func get_elements_in_range(position : Vector3, radius : float) -> Array[OctreeElement]:
	var stack : Array[Octant] = [root]
	var ret : Array[OctreeElement]
	while !stack.is_empty():
		var look_at : Octant = stack.pop_front()
		var transformed_pos = position - look_at.center
		transformed_pos = transformed_pos.abs()
		var test1 = transformed_pos - (Vector3.ONE * -look_at.extend)
		if test1.length() < radius:
			var start = elements[look_at.start_index]
			for i in range(look_at.nr_of_elements - 1):
				ret.append(start)
				start = start.successor
		if look_at.is_leaf:
			var start = elements[look_at.start_index]
			for i in range(look_at.nr_of_elements - 1):
				if (start.position - position).length() < radius:
					ret.append(start)
				start = start.successor
		for child in look_at.children:
			transformed_pos = position - child.center
			transformed_pos = transformed_pos.abs()
			if Utility.vector_max(transformed_pos) < child.extend + radius:
				if (Utility.vector_min(transformed_pos) < child.extend or 
					(transformed_pos - (Vector3.ONE * child.extend)).length() < radius):
						stack.append(child)
	return []
