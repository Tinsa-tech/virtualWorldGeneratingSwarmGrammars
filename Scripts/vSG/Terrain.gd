class_name Terrain extends Node3D

@export
var material : ShaderMaterial
@export
var mesh : MeshInstance3D
var size_x : int
var size_y : int
var distance_between_vertices : float

var vertices : PackedVector3Array
var normals : PackedVector3Array
var indices : PackedInt32Array

var avg_heights : Array[float] = []
var influence_factors : Array[float] = []

var influencers : Array[Artifact] = []
var new_influencers : Array[Artifact] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# generate_terrain(2, 100, 100)
	pass

func generate_terrain(dist_between_vertices : float, size : int):
	self.distance_between_vertices = dist_between_vertices
	self.size_x = size
	self.size_y = size
	
	var start_offset = Vector2((float(size_x) - 1) * distance_between_vertices / 2, 
							(float(size_y) - 1) * distance_between_vertices / 2)
	var surface_array : Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	for x in range(size_x):
		for y in range(size_y):
			var vertex = Vector3(x * distance_between_vertices - start_offset.x, 0, 
								y * distance_between_vertices - start_offset.y)
			vertices.append(vertex)
#			print("x: " + str(x) + " y: " + str(y) + " pos: " + str(vertex))
	
	for vert in vertices:
		normals.append(Vector3(0, 1, 0))
		avg_heights.append(0.0)
		influence_factors.append(0.0)
	
	for j in range(size_x  - 1):
		var offset = j * size_y
		for i in range(size_y - 1):
			var index = i + offset
			var max_index = len(vertices) - 1
			if index + size_y + 1 > max_index:
				break
			
			indices.append(index)
			indices.append(index + size_y)
			indices.append(index + 1)
			
			indices.append(index + 1)
			indices.append(index + size_y)
			indices.append(index + size_y + 1)
			
#			print("quad: " + str(index) + ", " + str(index + size_y) + ", "
#			+ str(index + 1) + "; " + str(index + 1) + ", " + str(index + size_y) 
#			+ ", " + str(index + size_y + 1))
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.mesh = ArrayMesh.new()
	mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.mesh.surface_set_material(0, material)
	
func get_height_at(point : Vector3) -> float:
	var x : float = point.x
	var y : float = point.z
	
	var x_vertex_pos = x + (float(size_x) - 1) * distance_between_vertices / 2
	var y_vertex_pos = y + (float(size_y) - 1) * distance_between_vertices / 2
	
	var p = Vector2(x, y)
	
	var x_low : int = floori(x)
	var y_low : int = floori(y)
	
	var start_index : int = floori(x_vertex_pos) * size_y + floori(y_vertex_pos)
	
	## if position we try to sample is outside of mesh return 0
	if (start_index + size_y + 1 >= len(vertices) or
		start_index < 0):
			return 0.0
	
	# we know which square the point is in, find out the triangle its on
	var v = x - float(x_low) + y - float(y_low)
	
	var A : Vector3
	var B : Vector3
	var C : Vector3
	
	if v <= 1:
		A = vertices[start_index]
		B = vertices[start_index + size_y]
		C = vertices[start_index + 1]
	else:
		A = vertices[start_index + 1]
		B = vertices[start_index + size_y]
		C = vertices[start_index + size_y + 1]
	
	var a : Vector2 = Vector2(A.x, A.z)
	var b : Vector2 = Vector2(B.x, B.z)
	var c : Vector2 = Vector2(C.x, C.z)
	
	var ap = p - a
	var bc = c - b
	
	var u = b - a
	var b_t = b.rotated(-0.5 * PI)
	
	if b_t.dot(a) == 0:
		return 0.0
	
	var a_x = b_t.dot(u) / b_t.dot(a)
	
	var s = a + ap * a_x

	var ass : Vector2 = s - a
	var bs : Vector2 = s - b
	
	if bc.length() == 0 or ap.length() == 0:
		return 0.0
	var h_s
	var quot
	if bc.length() == 0:
		h_s = B.y
	else:
		quot = bs.length() / bc.length()
		h_s = B.y * (1 - quot) + C.y * quot
	
	var p_h
	if ap.length() == 0:
		p_h = A.y
	else:
		quot = ass.length() / ap.length()
		p_h = A.y * (1 - quot) + h_s * quot
		
	# print("A: " + str(A) + " B: " + str(B) + " C: " + str(C) + " height: " + str(p_h) + " point: " + str(point))
	return p_h

func update_terrain() -> void:
	if new_influencers.size() == 0:
		return
	
	#for i in range(vertices.size()):
		#update_vertex(i)
	var task_id = WorkerThreadPool.add_group_task(update_vertex, vertices.size())
	WorkerThreadPool.wait_for_group_task_completion(task_id)
	
	influencers.append_array(new_influencers)
	new_influencers.clear()
	
	mesh.mesh.clear_surfaces()
	
	var surface_array : Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.mesh.surface_set_material(0, material)
			
		

func update_vertex(vertex_index : int):
	var vertex = vertices[vertex_index]
	var vertex_xz = Vector2(vertex.x, vertex.z)
	var avg_height : float = avg_heights[vertex_index]
	var influences : float = influence_factors[vertex_index]
	for influencer in new_influencers:
		var influencer_xz = Vector2(influencer.actor_position.x, influencer.actor_position.z)
		var dist = vertex_xz.distance_to(influencer_xz)
		var influence_fact : float = 1.0 / pow((1 + dist), influencer.influence_on_terrain)
		
		avg_height += influencer.actor_position.y * influence_fact
		influences += influence_fact
	
	avg_heights[vertex_index] = avg_height
	influence_factors[vertex_index] = influences
	# print("vert_id: " + str(vertex_index) + " avg height: " + str(avg_height) + " influences: " + str(influences))
	avg_height /= influences
	vertex = Vector3(vertex.x, avg_height, vertex.z)
	vertices[vertex_index] = vertex

func smooth_normals():
	var vertex_normals : Array = []
	vertex_normals.resize(vertices.size())
	var i = 0
	while i < indices.size() - 2:
		var p0 = vertices[indices[i]]
		var p1 = vertices[indices[i + 1]]
		var p2 = vertices[indices[i + 2]]
		
		var normal : Vector3 = (p1 - p0).cross(p2 - p0)
		
		var a0 = (p1 - p0).angle_to(p2 - p0)
		var a1 = (p2 - p1).angle_to(p0 - p1)
		var a2 = (p0 - p2).angle_to(p1 - p2)
		
		if !vertex_normals[indices[i]]:
			vertex_normals[indices[i]] = [normal * a0]
		else:
			vertex_normals[indices[i]].append(normal * a0)
		
		if !vertex_normals[indices[i + 1]]:
			vertex_normals[indices[i + 1]] = [normal * a1]
		else:
			vertex_normals[indices[i + 1]].append(normal * a1)
		
		if !vertex_normals[indices[i + 2]]:
			vertex_normals[indices[i + 2]] = [normal * a2]
		else:
			vertex_normals[indices[i + 2]].append(normal * a2)
		
		i += 3
	
	for v in range(vertices.size()):
		var normal : Vector3
		
		for v_normal in vertex_normals[v]:
			normal = normal + v_normal
		
		normal = normal.normalized()
		normals[v] = -normal
	
	mesh.mesh.clear_surfaces()
	
	var surface_array : Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.mesh.surface_set_material(0, material)
	
func add_influencer(influencer : Artifact):
	new_influencers.append(influencer)

func _on_influencer_moved():
	new_influencers.append_array(influencers.duplicate())
	influencers.clear()
	for i in range(vertices.size()):
		avg_heights[i] = 0.0
		influence_factors[i] = 0.0
	update_terrain()
