class_name AgentObject extends ActorObject

func instantiate() -> void:
	var agent : Agent = actor
	agent.forward = -self.basis.z

func update_position(terrain : Terrain):
	var agent : Agent = actor
	agent.update_position(terrain)
	self.position = agent.actor_position
	if agent.velocity.length() > 0:
		look_at(self.position + agent.velocity)
	agent.forward = -self.basis.z
