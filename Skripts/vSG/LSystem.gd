class_name LSystem

var productions : Array[Production]

func apply_productions(actors : Array[Actor]) -> Array:
	var ids_apply_productions_to : Array[int]
	var persist : Array[bool]
	var types_to_instantiate : Array[Array]
	
	for agent in actors:
		if not agent is Agent:
			continue
		if agent.energy <= 0.0:
			ids_apply_productions_to.append(agent.id)
			persist.append(false)
			types_to_instantiate.append(agent.energy_calculations.zero_successors)
			continue
		
		var applicable_prods : Array[Production]
		for production in productions:
			if agent.type == production.predecessor:
				if production.context:
					for context in actors:
						if (context.type == production.context and 
								(context.position - agent.position).length() < production.distance):
							applicable_prods.append(production)
				else:
					applicable_prods.append(production)
		
		var select_random : Array[Production]
		for production in applicable_prods:
			for i in range(production.theta):
				select_random.append(production)
		
		var rng = RandomNumberGenerator.new()
		var index = rng.randi_range(0, len(select_random) - 1)
		ids_apply_productions_to.append(agent.id)
		persist.append(select_random[index].persist)
		types_to_instantiate.append(select_random[index].successor)
	return [ids_apply_productions_to, persist, types_to_instantiate]
