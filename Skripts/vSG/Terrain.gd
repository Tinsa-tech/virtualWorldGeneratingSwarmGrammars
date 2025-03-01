class_name Terrain

extends Node

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
	
	var x_vertex_pos = x - (float(size_x) - 1) * distance_between_vertices / 2
	var y_vertex_pos = y - (float(size_y) - 1) * distance_between_vertices / 2
	
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
	
	var a_x = b_t.dot(u) / b_t.dot(a)
	
	var s = a + ap * a_x

	var ass : Vector2 = s - a
	var bs : Vector2 = s - b

	var h_s = (B.y + C.y) * (bs.length() / bc.length())
	var p_h = (h_s + A.y) * (ass.length() / ap.length())
	return p_h

func update_terrain(artifacts : Array[ArtifactObject]) -> void:
	var influencers : Array[Artifact]
	for artifact_obj in artifacts:
		var artifact = artifact_obj.actor
		if artifact.influence_on_terrain > 0:
			influencers.append(artifact)
	
	if len(influencers) == 0:
		return
	
	# var e = 0.0001
	var new_vertice_arr : Array
	
	for vertex in vertices:
		var vertex_xz = Vector2(vertex.x, vertex.z)
		var avg_height : float = 0.0
		var influences : float = 0.0
		
		for influencer in influencers:
			var influencer_xz = Vector2(influencer.actor_position.x, influencer.actor_position.z)
			var dist = vertex_xz.distance_to(influencer_xz)
			var influence_fact : float = 1.0 / pow((1 + dist), influencer.influence_on_terrain)
			
			avg_height += (influencer.actor_position.y - vertex.y) * influence_fact
			influences += influence_fact
		
		avg_height /= influences
		var new_vertex = Vector3(vertex.x, vertex.y + avg_height, vertex.z)
		new_vertice_arr.append(new_vertex)
	
	vertices = new_vertice_arr.duplicate(true)
	mesh.mesh.clear_surfaces()
	
	var surface_array : Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.mesh.surface_set_material(0, material)
			
		

	
