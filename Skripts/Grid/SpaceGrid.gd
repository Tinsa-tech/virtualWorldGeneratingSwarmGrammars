class_name SpaceGrid

var cells : Array[GridCell] = []
var cell_nr : int
var cell_nr_sq : int

var cell_size : float
var size : float

func _init(grid_size : float, grid_cell_size : float):
	cell_size = grid_cell_size
	size = grid_size
	
	cell_nr = floor(grid_size / grid_cell_size)
	cells.resize(int(pow(cell_nr, 3)))
	cell_nr_sq = int(pow(cell_nr, 2))

func add_element(grid_element : GridElement):
	var pos = grid_element.position
	var offset = size / 2
	pos = Vector3(pos.x + offset, pos.y + offset, pos.z + offset)
	pos = pos / cell_size
	pos = pos.floor()
	var index = pos.x * cell_nr_sq + pos.y * cell_nr + pos.z
	if index <= 0 or index >= cells.size() or is_nan(index):
		return
	var cell = cells[index]
	if !cell:
		cell = GridCell.new()
		cell.index = index
		cell.position = pos
		var neighbours = get_neighbours_cell(cell)
		for neighbour in neighbours:
			if !neighbour:
				continue
			cell.neighbours.append(neighbour)
	
	cell.add_element(grid_element)

func get_neighbours_cell(cell : GridCell) -> Array[int]:
	if !cell:
		return []
	
	var pos = cell.position
	var neighbours : Array[int] = []
	
	var x : int = int(pos.x) * cell_nr_sq
	var y : int = int(pos.y) * cell_nr
	var z : int = int(pos.z)
	
	var x_p : int = (int(pos.x) + 1) * cell_nr_sq
	var x_m : int = (int(pos.x) - 1) * cell_nr_sq
	
	var y_p : int = (int(pos.y) + 1) * cell_nr
	var y_m : int = (int(pos.y) - 1) * cell_nr
	
	
	if pos.x - 1 >= 0:
		if pos.y - 1 >= 0:
			if pos.z - 1 >= 0:
				neighbours.append(x_m + y_m + z - 1)
			neighbours.append(x_m + y_m + z)
			if pos.z + 1 <= cell_nr - 1:
				neighbours.append(x_m + y_m + z + 1)
		if pos.z - 1 >= 0:
			neighbours.append(x_m + y + z - 1)
		neighbours.append(x_m + y + z)
		if pos.z + 1 <= cell_nr - 1:
			neighbours.append(x_m + y + z + 1)
		if pos.y + 1 <= cell_nr - 1:
			if pos.z - 1 >= 0:
				neighbours.append(x_m + y_p + z - 1)
			neighbours.append(x_m + y_p + z)
			if pos.z + 1 <= cell_nr - 1:
				neighbours.append(x_m + y_p + z + 1)
	
	if pos.y - 1 >= 0:
		if pos.z - 1 >= 0:
			neighbours.append(x + y_m + z - 1)
		neighbours.append(x + y_m + z)
		if pos.z + 1 <= cell_nr - 1:
			neighbours.append(x + y_m + z + 1)
	if pos.z - 1 >= 0:
		neighbours.append(x + y + z - 1)
	neighbours.append(x + y + z)
	if pos.z + 1 <= cell_nr - 1:
		neighbours.append(x + y + z + 1)
	if pos.y + 1 <= cell_nr - 1:
		if pos.z - 1 >= 0:
			neighbours.append(x + y_p + z - 1)
		neighbours.append(x + y_p + z)
		if pos.z + 1 <= cell_nr - 1:
			neighbours.append(x + y_p + z + 1)
	
	if pos.x + 1 <= cell_nr - 1:
		if pos.y - 1 >= 0:
			if pos.z - 1 >= 0:
				neighbours.append(x_p + y_m + z - 1)
			neighbours.append(x_p + y_m + z)
			if pos.z + 1 <= cell_nr - 1:
				neighbours.append(x_p + y_m + z + 1)
		if pos.z - 1 >= 0:
			neighbours.append(x_p + y + z - 1)
		neighbours.append(x_p + y + z)
		if pos.z + 1 <= cell_nr - 1:
			neighbours.append(x_p + y + z + 1)
		if pos.y + 1 <= cell_nr - 1:
			if pos.z - 1 >= 0:
				neighbours.append(x_p + y_p + z - 1)
			neighbours.append(x_p + y_p + z)
			if pos.z + 1 <= cell_nr - 1:
				neighbours.append(x_p + y_p + z + 1)
	return neighbours

func remove_element(grid_element : GridElement):
	var cell : GridCell = grid_element.grid_cell
	cell.remove_element(grid_element)
	grid_element.grid_cell = null
	if cell.nr_elements == 0:
		for neighbour : int in cell.neighbours:
			cells[neighbour].neighbours.erase(cell.index)
		cell.neighbours.clear()
		cells[cell.index] = null

func update_grid():
	for cell in cells:
		if !cell:
			continue
		if cell.nr_elements <= 0:
			continue
		var elements = cell.elements
		for element : GridElement in elements:
			element.position = element.obj.actor.actor_position
			var index = get_index_from_position(element.position)
			if index == cell.index:
				continue
			elif index >= cells.size() or index < 0:
				cell.remove_element(element)
			else:
				cell.remove_element(element)
				cells[index].add_element(element)

func get_neigbours(position : Vector3, radius : float) -> Array[GridElement]:
	var ret : Array[GridElement] = []
	var index = get_index_from_position(position)
	if index >= cells.size() or index < 0 or is_nan(index):
		return []
	var cell = cells[index];
	if !cell:
		return []
	if radius <= cell_size:
		ret.append_array(cell.elements)
		for neighbour in cell.neighbours:
			ret.append_array(cells[neighbour].elements)
	else:
		var depth = radius / cell_size
		depth = ceili(depth)
		var neighbours : Array[int] = []
		var look_at : Array[int] = []
		var new_neighbours : Array[int] = []
		new_neighbours.append(cell)
		for i in range(depth):
			look_at.clear()
			for new_neighbour in new_neighbours:
				for neighbour in cells[new_neighbour].neighbours:
					if neighbours.find(neighbour) == -1:
						look_at.append(neighbour)
						neighbours.append(neighbour)
			new_neighbours.clear()
			new_neighbours.append_array(look_at)
		
		for neighbour in neighbours:
			ret.append_array(cells[neighbour].elements)
	return ret

func get_index_from_position(position : Vector3) -> int:
	var pos = position
	var offset = size / 2
	pos = Vector3(pos.x + offset, pos.y + offset, pos.z + offset)
	pos = pos / cell_size
	pos = pos.floor()
	return pos.x * cell_nr_sq + pos.y * cell_nr + pos.z

func clean_up():
	for cell in cells:
		if !cell:
			continue
		if cell.nr_elements <= 0:
			continue
		
		var elements = cell.elements.duplicate(true)
		for element in elements:
			cell.remove_element(element)
		
		cell.elements.clear()
		elements.clear()
		
		cells[cell.index] = null
