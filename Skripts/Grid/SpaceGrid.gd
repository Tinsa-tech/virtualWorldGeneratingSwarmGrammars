class_name SpaceGrid

var cells : Array[GridCell] = []
var cell_nr : int

var cell_size : float
var size : float

func _init(grid_size : float, grid_cell_size : float):
	cell_size = grid_cell_size
	size = grid_size
	
	var offset = grid_size / 2
	var cell_nr = floor(grid_size / grid_cell_size)
	# cells.resize(pow(cell_nr, 3))
	for x in range(cell_nr):
		for y in range(cell_nr):
			for z in range(cell_nr):
				var cell = GridCell.new()
				cell.position = Vector3(x * cell_size - offset,
					y * cell_size - offset,
					z * cell_size - offset)
				cell.index = cells.size()
				cells.append(cell)
	
	for cell in cells:
		var pos = cell.position
		pos = pos + Vector3(offset, offset, offset)
		pos = pos / cell_size
		pos = pos.floor()
		
		var cell_nr_sq = pow(cell_nr, 2)
		var x = pos.x * cell_nr_sq
		var y = pos.y * cell_nr
		var z = pos.z
		var x_m = (pos.x - 1) * cell_nr_sq
		var x_p = (pos.x + 1) * cell_nr_sq
		var y_m = (pos.y - 1) * cell_nr
		var y_p = (pos.y + 1) * cell_nr
		
		if pos.x - 1 >= 0:
			if pos.y - 1 >= 0:
				if pos.z - 1 >= 0:
					cell.neighbours.append(cells[x_m + y_m + z - 1])
				cell.neighbours.append(cells[x_m + y_m + z])
				if pos.z + 1 <= cell_nr - 1:
					cell.neighbours.append(cells[x_m + y_m + z + 1])
			if pos.z - 1 >= 0:
				cell.neighbours.append(cells[x_m + y + z - 1])
			cell.neighbours.append(cells[x_m + y + z])
			if pos.z + 1 <= cell_nr - 1:
				cell.neighbours.append(cells[x_m + y + z + 1])
			if pos.y + 1 <= cell_nr - 1:
				if pos.z - 1 >= 0:
					cell.neighbours.append(cells[x_m + y_p + z - 1])
				cell.neighbours.append(cells[x_m + y_p + z])
				if pos.z + 1 <= cell_nr - 1:
					cell.neighbours.append(cells[x_m + y_p + z + 1])
		
		if pos.y - 1 >= 0:
			if pos.z - 1 >= 0:
				cell.neighbours.append(cells[x + y_m + z - 1])
			cell.neighbours.append(cells[x + y_m + z])
			if pos.z + 1 <= cell_nr - 1:
				cell.neighbours.append(cells[x + y_m + z + 1])
		if pos.z - 1 >= 0:
			cell.neighbours.append(cells[x + y + z - 1])
		cell.neighbours.append(cells[x + y + z])
		if pos.z + 1 <= cell_nr - 1:
			cell.neighbours.append(cells[x + y + z + 1])
		if pos.y + 1 <= cell_nr - 1:
			if pos.z - 1 >= 0:
				cell.neighbours.append(cells[x + y_p + z - 1])
			cell.neighbours.append(cells[x + y_p + z])
			if pos.z + 1 <= cell_nr - 1:
				cell.neighbours.append(cells[x + y_p + z + 1])
		
		if pos.x + 1 <= cell_nr - 1:
			if pos.y - 1 >= 0:
				if pos.z - 1 >= 0:
					cell.neighbours.append(cells[x_p + y_m + z - 1])
				cell.neighbours.append(cells[x_p + y_m + z])
				if pos.z + 1 <= cell_nr - 1:
					cell.neighbours.append(cells[x_p + y_m + z + 1])
			if pos.z - 1 >= 0:
				cell.neighbours.append(cells[x_p + y + z - 1])
			cell.neighbours.append(cells[x_p + y + z])
			if pos.z + 1 <= cell_nr - 1:
				cell.neighbours.append(cells[x_p + y + z + 1])
			if pos.y + 1 <= cell_nr - 1:
				if pos.z - 1 >= 0:
					cell.neighbours.append(cells[x_p + y_p + z - 1])
				cell.neighbours.append(cells[x_p + y_p + z])
				if pos.z + 1 <= cell_nr - 1:
					cell.neighbours.append(cells[x_p + y_p + z + 1])
			

func add_element(grid_element : GridElement):
	var pos = grid_element.position
	pos = pos / cell_size
	pos = pos.floor()
	var index = pos.x * cell_nr * cell_nr + pos.y * cell_nr + pos.z
	cells[index].add_element(grid_element)

func remove_element(grid_element : GridElement):
	grid_element.grid_cell.remove_element(grid_element)

func update_grid():
	for cell in cells:
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
	if index >= cells.size() or index < 0:
		return []
	var cell = cells[index];
	if radius <= cell_size:
		ret.append_array(cell.elements)
		for neighbour in cell.neighbours:
			ret.append_array(neighbour.elements)
	else:
		var depth = radius / cell_size
		depth = ceili(depth)
		var neighbours : Array[GridCell] = []
		var look_at : Array[GridCell] = []
		var new_neighbours : Array[GridCell] = []
		new_neighbours.append(cell)
		for i in range(depth):
			look_at.clear()
			for new_neighbour in new_neighbours:
				for neighbour in new_neighbour.neighbours:
					if neighbours.find(neighbour) == -1:
						look_at.append(neighbour)
						neighbours.append(neighbour)
			new_neighbours.clear()
			new_neighbours.append_array(look_at)
		
		for neighbour in neighbours:
			ret.append_array(neighbour.elements)
	return ret

func get_index_from_position(position : Vector3) -> int:
	var pos = position
	pos = pos / cell_size
	pos = pos.floor()
	return pos.x * cell_nr * cell_nr + pos.y * cell_nr + pos.z
