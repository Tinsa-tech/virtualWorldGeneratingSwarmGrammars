class_name GridCell

var position : Vector3
var elements : Array[GridElement] = []

var neighbours : Array[Vector3] = []

var nr_elements : int = 0

func add_element(element : GridElement):
	element.grid_cell = self
	element.index_in_cell = elements.size()
	elements.append(element)
	nr_elements += 1

func remove_element(element : GridElement):
	var element_index = element.index_in_cell
	if element_index == nr_elements - 1:
		elements.pop_back()
		nr_elements -= 1
		return
	
	var last = elements.pop_back()
	last.index_in_cell = element_index

	elements[element_index] = last
	element.grid_cell = null
	nr_elements -= 1

func clean_up():
	for element in elements:
		element.disconnect_obj()
		element.grid_cell = null
	
	elements.clear()
	neighbours.clear()
