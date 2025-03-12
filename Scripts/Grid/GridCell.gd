class_name GridCell

var position : Vector3
var elements : Array[GridElement] = []

var neighbours : Array[int] = []

var index : int
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
	nr_elements -= 1
