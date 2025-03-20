class_name SpaceGrid

var cells : Dictionary = {}

var cell_size : float

func _init(grid_cell_size : float):
	cell_size = grid_cell_size
	

func add_element(grid_element : GridElement):
	var pos = grid_element.position
	pos = pos / cell_size
	pos = pos.floor()

	var cell : GridCell
	if !cells.has(pos):
		cell = GridCell.new()
		cell.position = pos
		var neighbours = get_neighbours_cell(cell)
		for neighbour in neighbours:
			if !cells.has(neighbour):
				continue
			cell.neighbours.append(neighbour)
		cells[pos] = cell
	else:
		cell = cells[pos]
	cell.add_element(grid_element)

func get_neighbours_cell(cell : GridCell) -> Array[Vector3]:
	if !cell:
		return []
	
	var pos = cell.position
	var neighbours : Array[Vector3] = []

	var x : int = int(pos.x)
	var y : int = int(pos.y) 
	var z : int = int(pos.z)
	
	neighbours.append(Vector3(x + 1, y + 1, z + 1))
	neighbours.append(Vector3(x + 1, y + 1, z))
	neighbours.append(Vector3(x + 1, y + 1, z - 1))
	neighbours.append(Vector3(x + 1, y, z + 1))
	neighbours.append(Vector3(x + 1, y, z))
	neighbours.append(Vector3(x + 1, y, z - 1))
	neighbours.append(Vector3(x + 1, y - 1, z + 1))
	neighbours.append(Vector3(x + 1, y - 1, z))
	neighbours.append(Vector3(x + 1, y - 1, z - 1))
	
	neighbours.append(Vector3(x, y + 1, z + 1))
	neighbours.append(Vector3(x, y + 1, z))
	neighbours.append(Vector3(x, y + 1, z - 1))
	neighbours.append(Vector3(x, y, z + 1))
	neighbours.append(Vector3(x, y, z))
	neighbours.append(Vector3(x, y, z - 1))
	neighbours.append(Vector3(x, y - 1, z + 1))
	neighbours.append(Vector3(x, y - 1, z))
	neighbours.append(Vector3(x, y - 1, z - 1))
	
	neighbours.append(Vector3(x - 1, y + 1, z + 1))
	neighbours.append(Vector3(x - 1, y + 1, z))
	neighbours.append(Vector3(x - 1, y + 1, z - 1))
	neighbours.append(Vector3(x - 1, y, z + 1))
	neighbours.append(Vector3(x - 1, y, z))
	neighbours.append(Vector3(x - 1, y, z - 1))
	neighbours.append(Vector3(x - 1, y - 1, z + 1))
	neighbours.append(Vector3(x - 1, y - 1, z))
	neighbours.append(Vector3(x - 1, y - 1, z - 1))
	
	return neighbours

func remove_element(grid_element : GridElement):
	var cell : GridCell = grid_element.grid_cell
	cell.remove_element(grid_element)
	grid_element.grid_cell = null
	if cell.nr_elements == 0:
		for neighbour : Vector3 in cell.neighbours:
			cells[neighbour].neighbours.erase(cell.position)
		cell.neighbours.clear()
		cells[cell.position] = null

func update_grid():
	for key in cells.keys():
		var cell = cells[key]
		if !cell:
			continue
		if cell.nr_elements <= 0:
			continue
		var elements = cell.elements
		for element : GridElement in elements:
			element.position = element.obj.actor.actor_position
			var pos = get_pos_from_position(element.position)
			if pos == cell.position:
				continue
			else:
				cell.remove_element(element)
				if cells.has(pos):
					cells[pos].add_element(element)
				else:
					var new_cell = GridCell.new()
					new_cell.position = pos
					var neighbours = get_neighbours_cell(new_cell)
					for neighbour in neighbours:
						if !cells.has(neighbour):
							continue
						new_cell.neighbours.append(neighbour)
					cells[pos] = cell
					new_cell.add_element(element)

func get_neigbours(position : Vector3, radius : float) -> Array[GridElement]:
	var ret : Array[GridElement] = []
	var pos = get_pos_from_position(position)
	if !cells.has(pos):
		return []
	var cell = cells[pos];
	if !cell:
		return []
	if radius <= cell_size:
		ret.append_array(cell.elements)
		for neighbour in cell.neighbours:
			ret.append_array(cells[neighbour].elements)
	else:
		var depth = radius / cell_size
		depth = ceili(depth)
		var neighbours : Array[Vector3] = []
		var look_at : Array[Vector3] = []
		var new_neighbours : Array[Vector3] = []
		new_neighbours.append(cell.position)
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

func get_pos_from_position(position : Vector3) -> Vector3:
	var pos = position
	pos = pos / cell_size
	pos = pos.floor()
	return pos

func clean_up():
	for key in cells.keys():
		var cell = cells[key]
		if !cell:
			continue
		if cell.nr_elements <= 0:
			continue
		
		cell.clean_up()
		
		cells[cell.position] = null
