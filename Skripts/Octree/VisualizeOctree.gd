class_name VisualizeOctree extends Node

var wireframe = preload("res://Scenes/WireframeCube.tscn")

func visualize(octree : Octree):
	for child in get_children():
		child.queue_free()
	
	var look_at : Array[Octant] = [octree.root]
	while !look_at.is_empty():
		var oct : Octant = look_at.pop_front()
		var wire : Node3D = wireframe.instantiate()
		wire.position = oct.center
		wire.scale = Vector3(oct.extend, oct.extend, oct.extend)
	
		add_child(wire)
		for child in oct.children:
			look_at.append(child)
