class_name ArtifactObject extends ActorObject

func set_color():
	var mi : MeshInstance3D = $Node3D2/MeshInstance3D
	var mat : StandardMaterial3D = mi.get_surface_override_material(0).duplicate()
	if actor.influence_on_terrain == 0:
		mat.albedo_color = Color.BLUE_VIOLET
	else:
		var v = float(actor.influence_on_terrain) / 10.0
		mat.albedo_color = Color.from_hsv(100.0 / 360.0, 1.0, v)
	mi.set_surface_override_material(0, mat)
