class_name AgentObject extends ActorObject


func instantiate() -> void:
	var agent : Agent = actor
	agent.forward = -self.basis.z

func update_position(terrain : Terrain, rng : Random):
	var agent : Agent = actor
	agent.update_position(terrain, rng)
	self.position = agent.actor_position
	if agent.velocity.length() > 0:
		var target = self.global_position + agent.velocity
		if self.global_position.is_equal_approx(target):
			target = self.global_position + agent.velocity.normalized()
		
		var up = Vector3.UP
		if up.cross(target - self.global_position).is_zero_approx():
			up = Vector3.RIGHT
			if up.cross(target - self.global_position).is_zero_approx():
				up = Vector3.FORWARD
		
		var v_z = (target - self.global_position).normalized()
		var v_x = up.cross(v_z)
		if v_x.is_zero_approx():
			up = Vector3.RIGHT
		
		
		#if actor.back_reference:
			# print("id: " + str(agent.id) + " type: " + str(agent.type) + " position: " + str(self.position) + " velocity: " + str(agent.velocity) + " pred id: " + str(actor.back_reference.id))
		
		#print("--------------------------------------------------")
		#print("target: " + str(target))
		#print("up: " + str(up))
		#print("position: " + str(self.global_position))
		#print("--------------------------------------------------")
		
		look_at(target, up)
		
	agent.forward = -self.basis.z

func set_color(new_color : Color):
	var mi : MeshInstance3D = $Node3D2/MeshInstance3D
	var mat : StandardMaterial3D = mi.get_surface_override_material(0).duplicate()
	
	mat.albedo_color = new_color
	mi.set_surface_override_material(0, mat)
	
