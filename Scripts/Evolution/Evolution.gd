class_name Evolution

var population : Array[EvolutionElement]
var mutation_probability = 0.05
var generation : int = 0

var save_path : String

func initialize_population(population_size : int):
	population = []
	for i in range(population_size):
		var ee = EvolutionElement.new()
		population.append(ee)
	
	if !DirAccess.dir_exists_absolute("user://EvoCSV"):
		DirAccess.make_dir_absolute("user://EvoCSV")
	save_path = "user://EvoCSV/" + Time.get_datetime_string_from_system().replace(":","") + ".csv"
	
	save_generation()

func perform_cycle():
	csv()
	
	## select parents
	var parents = fitness_proportional_selection()
	## recombine pairs of parents
	var offspring : Array[EvolutionElement] = recombine_parents(parents)
	## mutate offspring
	mutate(offspring)
	
	population = offspring
	generation += 1
	
	save_generation()

func fitness_proportional_selection() -> Array:
	## calculate the sum of all fitnesses:
	var sum_fitness : float = 0.0
	for member in population:
		sum_fitness += member.fitness
	
	var rng = RandomNumberGenerator.new()
	
	var parents : Array = []
	
	for i in range(population.size()):
		var random_nr = rng.randf()
		var selected : Array[EvolutionElement] = []
		
		for member in population:
			var prob = member.fitness / sum_fitness
			random_nr -= prob
			if random_nr <= 0:
				selected.append(member)
				break
		
		if selected.is_empty():
			selected.append(population.back())
		
		random_nr = rng.randf()
		
		for member in population:
			var prob = member.fitness / sum_fitness
			random_nr -= prob
			if random_nr <= 0:
				selected.append(member)
				break
		
		if selected.size() == 1:
			selected.append(population.back())
		
		parents.append(selected)
	
	return parents

func recombine_parents(parents : Array) -> Array[EvolutionElement]:
	var children : Array[EvolutionElement] = []
	
	for parent_pair in parents:
		var parent1 : EvolutionElement = parent_pair[0]
		var parent2 : EvolutionElement = parent_pair[1]
		
		var parent1_agents : Array[AgentTemplate] = []
		var parent1_artifacts : Array[ArtifactTemplate] = []
		for template in parent1.genotypes.templates:
			if template is AgentTemplate:
				parent1_agents.append(template)
			else:
				parent1_artifacts.append(template)
		var parent1_agents_mut : Array[AgentMutationStepSizes] = []
		var parent1_artifacts_mut : Array[ArtifactMutationStepSizes] = []
		for mutation in parent1.actors_mutation_step_sizes:
			if mutation is AgentMutationStepSizes:
				parent1_agents_mut.append(mutation)
			else:
				parent1_artifacts_mut.append(mutation)
		
		var parent2_agents : Array[AgentTemplate] = []
		var parent2_artifacts : Array[ArtifactTemplate] = []
		for template in parent2.genotypes.templates:
			if template is AgentTemplate:
				parent2_agents.append(template)
			else:
				parent2_artifacts.append(template)
		var parent2_agents_mut : Array[AgentMutationStepSizes] = []
		var parent2_artifacts_mut : Array[ArtifactMutationStepSizes] = []
		for mutation in parent2.actors_mutation_step_sizes:
			if mutation is AgentMutationStepSizes:
				parent2_agents_mut.append(mutation)
			else:
				parent2_artifacts_mut.append(mutation)
		
		var child_agents : Array[ActorTemplate] = []
		var child_mutation_sizes : Array[MutationStepSizes] = []
		
		var size
		if parent2_agents.size() > parent1_agents.size():
			size = parent1_agents.size()
		else:
			size = parent2_agents.size()
		
		for i in range(size):
			var template = AgentTemplate.new()
			var p1_template = parent1_agents[i]
			var p2_template = parent2_agents[i]
			
			template.a_max = blend_crossover(p1_template.a_max, p2_template.a_max)
			
			template.beta = blend_crossover(p1_template.beta, p2_template.beta)
			
			template.constraints.x = blend_crossover(p1_template.constraints.x, p2_template.constraints.x)
			template.constraints.y = blend_crossover(p1_template.constraints.y, p2_template.constraints.y)
			template.constraints.z = blend_crossover(p1_template.constraints.z, p2_template.constraints.z)
		
			for key in p1_template.distance_params.keys():
				template.distance_params[key] = blend_crossover(p1_template.distance_params[key], p2_template.distance_params[key])
			
			var energy = Energy.new()
			var p1_energy = p1_template.energy_calculations
			var p2_energy = p2_template.energy_calculations
			energy.move_value = blend_crossover(p1_energy.move_value, p2_energy.move_value)
			energy.predecessor_value = blend_crossover(p1_energy.predecessor_value, p2_energy.predecessor_value)
			energy.successor_value = blend_crossover(p1_energy.successor_value, p2_energy.successor_value)
			energy.successor_value_constdist = blend_crossover(p1_energy.successor_value_constdist, p2_energy.successor_value_constdist)
			energy.zero_energy = blend_crossover(p1_energy.zero_energy, p2_energy.zero_energy)
			
			energy.move_mode = uniform_crossover(p1_energy.move_mode, p2_energy.move_mode)
			energy.predecessor_mode = uniform_crossover(p1_energy.predecessor_mode, p2_energy.predecessor_mode)
			energy.successor_mode = uniform_crossover(p1_energy.successor_mode, p2_energy.successor_mode)
			
			energy.zero_successors = uniform_crossover_arrays(p1_energy.zero_successors, p2_energy.zero_successors)
			
			template.energy_calculations = energy
			
			for key in p1_template.influences.keys():
				if p2_template.influences.has(key):
					template.influences[key] = blend_crossover(p1_template.influences[key], p2_template.influences[key])
				else:
					template.influences[key] = p1_template.influences[key]
				
			for key in p2_template.influences.keys():
				if p1_template.influences.has(key):
					template.influences[key] = blend_crossover(p1_template.influences[key], p2_template.influences[key])
				else:
					template.influences[key] = p2_template.influences[key]
			
			for key in p1_template.movement_urges.keys():
				if key == Database.movement_urges.NOCLIP:
					template.movement_urges[key] = uniform_crossover(p1_template.movement_urges[key], p2_template.movement_urges[key])
				elif key == Database.movement_urges.BIAS:
					var bias_x = blend_crossover(p1_template.movement_urges[key].x, p2_template.movement_urges[key].x)
					var bias_y = blend_crossover(p1_template.movement_urges[key].y, p2_template.movement_urges[key].y)
					var bias_z = blend_crossover(p1_template.movement_urges[key].z, p2_template.movement_urges[key].z)
					template.movement_urges[key] = Vector3(bias_x, bias_y, bias_z)
				else:
					template.movement_urges[key] = blend_crossover(p1_template.movement_urges[key], p2_template.movement_urges[key])
			
			for key in p1_template.velocity_params.keys():
				template.velocity_params[key] = blend_crossover(p1_template.velocity_params[key], p2_template.velocity_params[key])
			
			template.type = "agent" + str(i)
			child_agents.append(template)
			
			var p1_mut : AgentMutationStepSizes = parent1_agents_mut[i]
			var p2_mut : AgentMutationStepSizes = parent2_agents_mut[i]
			
			var child_mut = AgentMutationStepSizes.new()
			
			child_mut.alignment = blend_crossover(p1_mut.alignment, p2_mut.alignment)
			child_mut.a_max = blend_crossover(p1_mut.a_max, p2_mut.a_max)
			child_mut.beta = blend_crossover(p1_mut.beta, p2_mut.beta)
			child_mut.bias_x = blend_crossover(p1_mut.bias_x, p2_mut.bias_x)
			child_mut.bias_y = blend_crossover(p1_mut.bias_y, p2_mut.bias_y)
			child_mut.bias_z = blend_crossover(p1_mut.bias_z, p2_mut.bias_z)
			child_mut.center = blend_crossover(p1_mut.center, p2_mut.center)
			child_mut.cohesion = blend_crossover(p1_mut.cohesion, p2_mut.cohesion)
			child_mut.constraints_x = blend_crossover(p1_mut.constraints_x, p2_mut.constraints_x)
			child_mut.constraints_y = blend_crossover(p1_mut.constraints_y, p2_mut.constraints_y)
			child_mut.constraints_z = blend_crossover(p1_mut.constraints_z, p2_mut.constraints_z)
			child_mut.distance_separation = blend_crossover(p1_mut.distance_separation, p2_mut.distance_separation)
			child_mut.distance_view = blend_crossover(p1_mut.distance_view, p2_mut.distance_view)
			child_mut.floor = blend_crossover(p1_mut.floor, p2_mut.floor)
			child_mut.gradient = blend_crossover(p1_mut.gradient, p2_mut.gradient)
			child_mut.influences = blend_crossover_arrays(p1_mut.influences, p2_mut.influences)
			child_mut.count += child_mut.influences.size()
			child_mut.move_energy = blend_crossover(p1_mut.move_energy, p2_mut.move_energy)
			child_mut.normal = blend_crossover(p1_mut.normal, p2_mut.normal)
			child_mut.pace = blend_crossover(p1_mut.pace, p2_mut.pace)
			child_mut.predecessor_energy = blend_crossover(p1_mut.predecessor_energy, p2_mut.predecessor_energy)
			child_mut.random = blend_crossover(p1_mut.random, p2_mut.random)
			child_mut.separation = blend_crossover(p1_mut.separation, p2_mut.separation)
			child_mut.slope = blend_crossover(p1_mut.slope, p2_mut.slope)
			child_mut.successor_const_dist_energy = blend_crossover(p1_mut.successor_const_dist_energy, p2_mut.successor_const_dist_energy)
			child_mut.successor_energy = blend_crossover(p1_mut.successor_energy, p2_mut.successor_energy)
			child_mut.velocity_max = blend_crossover(p1_mut.velocity_max, p2_mut.velocity_max)
			child_mut.velocity_norm = blend_crossover(p1_mut.velocity_norm, p2_mut.velocity_norm)
			child_mut.zero_energy = blend_crossover(p1_mut.zero_energy, p2_mut.zero_energy)
			
			child_mutation_sizes.append(child_mut)
		
		if parent1_agents.size() < parent2_agents.size():
			for i in range(size, parent2_agents.size()):
				child_agents.append(parent2_agents[i])
				child_mutation_sizes.append(parent2_agents_mut.pop_front())
		else:
			for i in range(size, parent1_agents.size()):
				child_agents.append(parent1_agents[i])
				child_mutation_sizes.append(parent1_agents_mut.pop_front())
		

			
		
		if parent1_artifacts.size() < parent2_artifacts.size():
			size = parent1_artifacts.size()
		else:
			size = parent2_artifacts.size()
		
		var child_artifacts : Array[ActorTemplate] = []
		#var child_artifacts_mut : Array[ArtifactMutationStepSizes] = []
		
		for i in range(size):
			var p1_a = parent1_artifacts[i]
			var p2_a = parent2_artifacts[i]
			
			var child_artifact : ArtifactTemplate = ArtifactTemplate.new()
			
			child_artifact.influence_on_terrain = blend_crossover(p1_a.influence_on_terrain, p2_a.influence_on_terrain)
			
			for key in p1_a.influences.keys():
				if p2_a.influences.has(key):
					child_artifact.influences[key] = blend_crossover(p1_a.influences[key], p2_a.influences[key])
				else:
					child_artifact.influences[key] = p1_a.influences[key]
			
			for key in p2_a.influences.keys():
				if child_artifact.influences.has(key):
					continue
				if p1_a.influences.has(key):
					child_artifact.influences[key] = blend_crossover(p1_a.influences[key], p2_a.influences[key])
				else:
					child_artifact.influences[key] = p2_a.influences[key]
			
			child_artifact.type = "artifact" + str(i)
			child_artifacts.append(child_artifact)
			
			var p1_mut = parent1_artifacts_mut.pop_front()
			var p2_mut = parent2_artifacts_mut.pop_front()
			
			var child_mut = ArtifactMutationStepSizes.new()
			
			child_mut.influence_on_terrain = blend_crossover(p1_mut.influence_on_terrain, p2_mut.influence_on_terrain)
			child_mut.influences = blend_crossover_arrays(p1_mut.influences, p2_mut.influences)
			child_mut.count += child_mut.influences.size()
			
			child_mutation_sizes.append(child_mut)
			
		
		if parent1_artifacts.size() < parent2_artifacts.size():
			for i in range(size, parent2_artifacts.size()):
				child_artifacts.append(parent2_artifacts[i])
				child_mutation_sizes.append(parent2_artifacts_mut.pop_front())
		elif parent1_artifacts.size() > parent2_artifacts.size():
			for i in range(size, parent1_artifacts.size()):
				child_artifacts.append(parent1_artifacts[i])
				child_mutation_sizes.append(parent1_artifacts_mut.pop_front())
		
		for agent in child_mutation_sizes:
			while agent.influences.size() < child_agents.size():
				agent.influences.append(1.0)
		
		if parent1.genotypes.productions.size() < parent2.genotypes.productions.size():
			size = parent1.genotypes.productions.size()
		else:
			size = parent2.genotypes.productions.size()
		
		var child_prods : Array[Production] = []
		
		var p1_prod_muts = parent1.productions_mutation_step_sizes.duplicate()
		var p2_prod_muts = parent2.productions_mutation_step_sizes.duplicate()
		
		var child_prod_muts : Array[ProductionMutationStepSize] = []
		
		for i in range(size):
			var p1_prod = parent1.genotypes.productions[i]
			var p2_prod = parent2.genotypes.productions[i]
			
			var child_prod : Production = Production.new()
			
			child_prod.context = uniform_crossover(p1_prod.context, p2_prod.context)
			child_prod.distance = blend_crossover(p1_prod.distance, p2_prod.distance)
			child_prod.persist = uniform_crossover(p1_prod.persist, p2_prod.persist)
			child_prod.predecessor = uniform_crossover(p1_prod.predecessor, p2_prod.predecessor)
			child_prod.successor = uniform_crossover_arrays(p1_prod.successor, p2_prod.successor)
			child_prod.theta = blend_crossover(p1_prod.theta, p2_prod.theta)
			
			child_prods.append(child_prod)
			
			var p1_prod_mut = p1_prod_muts.pop_front()
			var p2_prod_mut = p2_prod_muts.pop_front()
			
			var child_prod_mut : ProductionMutationStepSize = ProductionMutationStepSize.new()
			
			child_prod_mut.distance = blend_crossover(p1_prod_mut.distance, p2_prod_mut.distance)
			child_prod_mut.theta = blend_crossover(p1_prod_mut.theta, p2_prod_mut.theta)
			
			child_prod_muts.append(child_prod_mut)
		
		if parent1.genotypes.productions.size() < parent2.genotypes.productions.size():
			for i in range(size, parent2.genotypes.productions.size()):
				child_prods.append(parent2.genotypes.productions[i])
				child_prod_muts.append(p2_prod_muts.pop_front())
		elif parent1.genotypes.productions.size() > parent2.genotypes.productions.size():
			for i in range(size, parent1.genotypes.productions.size()):
				child_prods.append(parent1.genotypes.productions[i])
				child_prod_muts.append(p1_prod_muts.pop_front())
			
		var child_data = Database.new()
		child_data.templates = child_agents.duplicate()
		child_data.templates.append_array(child_artifacts)
		child_data.productions = child_prods
		
		child_data.first_generation.clear()
		
		child_data.first_generation = uniform_crossover_arrays(parent1.genotypes.first_generation, parent2.genotypes.first_generation)
		
		child_data.use_rng_seed = false
		
		child_data.create_colors()
		
		var child = EvolutionElement.new()
		child.genotypes = child_data
		child.actors_mutation_step_sizes = child_mutation_sizes
		child.productions_mutation_step_sizes = child_prod_muts
		
		child.parents = ["p1" + str(population.find(parent1)), "p2" + str(population.find(parent2))]
		
		children.append(child)
		
		
	
	return children

func mutate(offspring : Array[EvolutionElement]):
	for evo_element : EvolutionElement in offspring:
		adjust_step_sizes(evo_element)
		
		var first_generation = evo_element.genotypes.first_generation
		var agent_templates = []
		for template in evo_element.genotypes.templates:
			if template is AgentTemplate:
				agent_templates.append(template.type)
		
		first_generation = mutate_array(first_generation, agent_templates)
		
		for i in range(evo_element.genotypes.templates.size()):
			var actor = evo_element.genotypes.templates[i]
			
			if actor is ArtifactTemplate:
				var step_sizes : ArtifactMutationStepSizes = evo_element.actors_mutation_step_sizes[i]
				actor.influence_on_terrain = mutate_float(actor.influence_on_terrain, step_sizes.influence_on_terrain)
				var j = 0
				for key in actor.influences.keys():
					actor.influences[key] = mutate_float(actor.influences[key], step_sizes.influences[j])
					j += 1
			elif actor is AgentTemplate:
				var step_sizes : AgentMutationStepSizes = evo_element.actors_mutation_step_sizes[i]
				
				actor.a_max = mutate_float(actor.a_max, step_sizes.a_max)
				actor.beta = mutate_float(actor.beta, step_sizes.beta)
				actor.constraints.x = mutate_float(actor.constraints.x, step_sizes.constraints_x)
				actor.constraints.y = mutate_float(actor.constraints.y, step_sizes.constraints_y)
				actor.constraints.z = mutate_float(actor.constraints.z, step_sizes.constraints_z)
				actor.seed = mutate_bool(actor.seed)
				
				actor.distance_params[Database.distance_params.VIEW] = mutate_float(actor.distance_params[Database.distance_params.VIEW], step_sizes.distance_view)
				actor.distance_params[Database.distance_params.SEPARATION] = mutate_float(actor.distance_params[Database.distance_params.SEPARATION], step_sizes.distance_separation)
				
				actor.movement_urges[Database.movement_urges.SEPARATION] = mutate_float(actor.movement_urges[Database.movement_urges.SEPARATION], step_sizes.separation)
				actor.movement_urges[Database.movement_urges.ALIGNMENT] = mutate_float(actor.movement_urges[Database.movement_urges.ALIGNMENT], step_sizes.alignment)
				actor.movement_urges[Database.movement_urges.COHESION] = mutate_float(actor.movement_urges[Database.movement_urges.COHESION], step_sizes.cohesion)
				actor.movement_urges[Database.movement_urges.RANDOM] = mutate_float(actor.movement_urges[Database.movement_urges.RANDOM], step_sizes.random)
				actor.movement_urges[Database.movement_urges.BIAS].x = mutate_float(actor.movement_urges[Database.movement_urges.BIAS].x, step_sizes.bias_x)
				actor.movement_urges[Database.movement_urges.BIAS].y = mutate_float(actor.movement_urges[Database.movement_urges.BIAS].y, step_sizes.bias_y)
				actor.movement_urges[Database.movement_urges.BIAS].z = mutate_float(actor.movement_urges[Database.movement_urges.BIAS].z, step_sizes.bias_z)
				actor.movement_urges[Database.movement_urges.CENTER] = mutate_float(actor.movement_urges[Database.movement_urges.CENTER], step_sizes.center)
				actor.movement_urges[Database.movement_urges.FLOOR] = mutate_float(actor.movement_urges[Database.movement_urges.FLOOR], step_sizes.floor)
				actor.movement_urges[Database.movement_urges.NORMAL] = mutate_float(actor.movement_urges[Database.movement_urges.NORMAL], step_sizes.normal)
				actor.movement_urges[Database.movement_urges.GRADIENT] = mutate_float(actor.movement_urges[Database.movement_urges.GRADIENT], step_sizes.gradient)
				actor.movement_urges[Database.movement_urges.SLOPE] = mutate_float(actor.movement_urges[Database.movement_urges.SLOPE], step_sizes.slope)
				actor.movement_urges[Database.movement_urges.PACE] = mutate_float(actor.movement_urges[Database.movement_urges.PACE], step_sizes.pace)
				
				actor.movement_urges[Database.movement_urges.NOCLIP] = mutate_bool(actor.movement_urges[Database.movement_urges.NOCLIP])
				
				var energy : Energy = actor.energy_calculations
				energy.move_value = mutate_float(energy.move_value, step_sizes.move_energy)
				energy.successor_value = mutate_float(energy.successor_value, step_sizes.successor_energy)
				energy.successor_value_constdist = mutate_float(energy.successor_value_constdist, step_sizes.successor_const_dist_energy)
				energy.predecessor_value = mutate_float(energy.predecessor_value, step_sizes.predecessor_energy)
				energy.zero_energy = mutate_float(energy.zero_energy, step_sizes.zero_energy)
				
				var names : Array = []
				for template in evo_element.genotypes.templates:
					names.append(template.type)
				
				energy.zero_successors = mutate_array(energy.zero_successors, names)
				
				# WARNING idk if it work like that with the enum stuff
				energy.successor_mode = mutate_enum(energy.successor_mode, Energy.successor)
				energy.predecessor_mode = mutate_enum(energy.predecessor_mode, Energy.predecessor)
				energy.move_mode = mutate_enum(energy.move_mode, Energy.move)
				
				actor.energy_calculations = energy
				
				var j = 0
				for key in actor.influences.keys():
					actor.influences[key] = mutate_float(actor.influences[key], step_sizes.influences[j])
					j += 1
				
				actor.velocity_params[Database.velocity_params.NORM] = mutate_float(actor.velocity_params[Database.velocity_params.NORM], step_sizes.velocity_norm)
				actor.velocity_params[Database.velocity_params.MAX] = mutate_float(actor.velocity_params[Database.velocity_params.MAX], step_sizes.velocity_max)
		
		for i in range(evo_element.genotypes.productions.size()):
			var prod : Production = evo_element.genotypes.productions[i]
			var step_sizes : ProductionMutationStepSize = evo_element.productions_mutation_step_sizes[i]
			
			var names : Array = []
			var agents : Array = []
			for template in evo_element.genotypes.templates:
				names.append(template.type)
				if template is AgentTemplate:
					agents.append(template.type)
							
			prod.context = mutate_string(prod.context, names)
			prod.distance = mutate_float(prod.distance, step_sizes.distance)
			prod.persist = mutate_bool(prod.persist)
			prod.predecessor = mutate_string(prod.predecessor, agents)
			prod.successor = mutate_array(prod.successor, names)
			prod.theta = mutate_float(prod.theta, step_sizes.theta)

func adjust_step_sizes(evo_element : EvolutionElement):
	var n = 0
	for steps in evo_element.actors_mutation_step_sizes:
		n += steps.count
	for prod in evo_element.productions_mutation_step_sizes:
		n += prod.count
	
	for mss in evo_element.actors_mutation_step_sizes:
		if mss is ArtifactMutationStepSizes:
			mss.influence_on_terrain = adjust_step_size_float(mss.influence_on_terrain, n)
			for i in range(mss.influences.size()):
				mss.influences[i] = adjust_step_size_float(mss.influences[i], n)
		elif mss is AgentMutationStepSizes:
			mss.alignment = adjust_step_size_float(mss.alignment, n)
			mss.a_max = adjust_step_size_float(mss.a_max, n)
			mss.beta = adjust_step_size_float(mss.beta, n)
			mss.bias_x = adjust_step_size_float(mss.bias_x, n)
			mss.bias_y = adjust_step_size_float(mss.bias_y, n)
			mss.bias_z = adjust_step_size_float(mss.bias_z, n)
			mss.center = adjust_step_size_float(mss.center, n)
			mss.cohesion = adjust_step_size_float(mss.cohesion, n)
			mss.constraints_x = adjust_step_size_float(mss.constraints_x, n)
			mss.constraints_y = adjust_step_size_float(mss.constraints_y, n)
			mss.constraints_z = adjust_step_size_float(mss.constraints_z, n)
			mss.distance_separation = adjust_step_size_float(mss.distance_separation, n)
			mss.distance_view = adjust_step_size_float(mss.distance_view, n)
			mss.floor = adjust_step_size_float(mss.floor, n)
			mss.gradient = adjust_step_size_float(mss.gradient, n)
			
			for i in range(mss.influences.size()):
				mss.influences[i] = adjust_step_size_float(mss.influences[i], n)
			
			mss.move_energy = adjust_step_size_float(mss.move_energy, n)
			mss.normal = adjust_step_size_float(mss.normal, n)
			mss.pace = adjust_step_size_float(mss.pace, n)
			mss.predecessor_energy = adjust_step_size_float(mss.predecessor_energy, n)
			mss.random = adjust_step_size_float(mss.random, n)
			mss.separation = adjust_step_size_float(mss.separation, n)
			mss.slope = adjust_step_size_float(mss.slope, n)
			mss.successor_const_dist_energy = adjust_step_size_float(mss.successor_const_dist_energy, n)
			mss.successor_energy = adjust_step_size_float(mss.successor_energy, n)
			mss.velocity_max = adjust_step_size_float(mss.velocity_max, n)
			mss.velocity_norm = adjust_step_size_float(mss.velocity_norm, n)
			mss.zero_energy = adjust_step_size_float(mss.zero_energy, n)
	
	for mss in evo_element.productions_mutation_step_sizes:
		mss.distance = adjust_step_size_float(mss.distance, n)
		mss.theta = adjust_step_size_float(mss.theta, n)

func adjust_step_size_float(step_size : float, n : int) -> float:
	var tau = 1 / sqrt(2 * sqrt(n))
	var tau_dash = 1 / sqrt(2 * n)
	
	var e = 2.718282
	
	var threshhold = 0.1
	var rng = RandomNumberGenerator.new()
	
	# TODO wrong we should use one random value to be multiplied with tau for all step sizes i think	
	var value = step_size * pow(e, tau_dash * rng.randfn() + tau * rng.randfn())
	if value < threshhold:
		value = threshhold
	step_size = value
	return step_size

func mutate_float(value : float, step_size : float) -> float:
	var rng = RandomNumberGenerator.new()
	if rng.randf() > mutation_probability:
		return value
	value = value + step_size * rng.randfn()
	return value

func mutate_bool(value : bool) -> bool:
	var rng = RandomNumberGenerator.new()
	if rng.randf() > mutation_probability:
		return value
	value = !value
	return value

func mutate_enum(value : int, enum_dict : Dictionary) -> int:
	var rng = RandomNumberGenerator.new()
	if rng.randf() > mutation_probability:
		return value
	var size = enum_dict.keys().size() - 1
	value = randi_range(0, size)
	return value

func mutate_array(value : Array, data : Array) -> Array:
	var rng = RandomNumberGenerator.new()
	if rng.randf() > mutation_probability:
		return value
	if rng.randf() > 0.1:
		if value.size() == 0:
			return value
		var size = value.size()
		var index = rng.randi_range(0, size - 1)
		var data_size = data.size()
		var data_index = rng.randi_range(0, data_size - 1)
		value[index] = data[data_index]
	else:
		if rng.randf() >= 0.5:
			if value.size() == 0:
				return value
			value.resize(value.size() - 1)
		else:
			var data_index = rng.randi_range(0, data.size() - 1)
			value.append(data[data_index])
	return value

func mutate_string(value : String, data : Array) -> String:
	var rng = RandomNumberGenerator.new()
	if rng.randf() > mutation_probability:
		return value
	var data_index = randi_range(0, data.size() - 1)
	value = data[data_index]
	return value


func blend_crossover(value1 : float, value2 : float) -> float:
	var rng = RandomNumberGenerator.new()
	var u = rng.randf()
	var dist = abs(value1 - value2)
	var avg = (value1 + value2) / 2
	var alpha = 1
	
	var up = avg + dist * alpha
	var low = avg - dist * alpha
	
	return (1 - u) * up + u * low
	
func uniform_crossover(value1, value2):
	var rng = RandomNumberGenerator.new()
	var p = 0.5
	var random = rng.randf()
	
	if p >= random:
		return value1
	else:
		return value2
	
func uniform_crossover_arrays(array1 : Array[String], array2 : Array[String]) -> Array[String]:
	var ret : Array[String] = []
	var size_diff = array1.size() - array2.size()
	var lower_size
	if size_diff >= 0:
		lower_size = array2.size()
	else:
		lower_size = array1.size()
	
	for i in range(lower_size):
		ret.append(uniform_crossover(array1[i], array2[i]))
	
	if size_diff > 0:
		for i in range(lower_size, lower_size + size_diff):
			ret.append(array1[i])
	elif size_diff < 0:
		for i in range(lower_size, lower_size + size_diff):
			ret.append(array2[i])
	return ret

func blend_crossover_arrays(array1 : Array[float], array2 : Array[float]) -> Array[float]:
	var ret : Array[float] = []
	var size_diff = array1.size() - array2.size()
	var lower_size
	if size_diff >= 0:
		lower_size = array2.size()
	else:
		lower_size = array1.size()
	
	for i in range(lower_size):
		ret.append(blend_crossover(array1[i], array2[i]))
	
	if size_diff > 0:
		for i in range(lower_size, lower_size + size_diff):
			ret.append(array1[i])
	elif size_diff < 0:
		for i in range(lower_size, lower_size + size_diff):
			ret.append(array2[i])
	return ret
	
func save_generation():
	var p = ProjectSettings.globalize_path("res://")
	var path_parts : PackedStringArray = p.split("/", false)
	var path : String = ""
	for i in range(path_parts.size() - 1):
		var part = path_parts[i]
		path += part + "/"
	path += "Evo/gen" + str(generation)
	DirAccess.make_dir_recursive_absolute(path)
	for i in range(population.size()):
		var member = population[i]
		member.genotypes.save_data(path + "/type" + str(i) + ".json")
	
func csv():

	var write_to_file = "Gen" + str(generation) + "\n"
	for evo_ele in population:
		var e_dict = evo_ele.to_dict()
		var agents = e_dict["Data"]["agents"]
		var artifacts = e_dict["Data"]["artifacts"]
		var productions = e_dict["Data"]["productions"]
		
		var mms_agents = e_dict["MutationStepSizes"]["Agents"]
		var mms_artifacts = e_dict["MutationStepSizes"]["Artifacts"]
		var mms_productions = e_dict["MutationStepSizes"]["Productions"]
		
		write_to_file += "fitness:," + str(e_dict["Fitness"]) + "\n"
		write_to_file += "parents:,"
		for parent in evo_ele.parents:
			write_to_file += parent + ","
		write_to_file += "\n"
		
		var value_q : Array = [agents[0]]
		while !value_q.is_empty():
			var value = value_q.pop_front()
			if value is Dictionary:
				for key in value.keys():
					if value[key] is Dictionary:
						value_q.append(value[key])
					else:
						write_to_file += key + ","
		# write_to_file += ","
		value_q = [artifacts[0]]
		while !value_q.is_empty():
			var value = value_q.pop_front()
			if value is Dictionary:
				for key in value.keys():
					if value[key] is Dictionary:
						value_q.append(value[key])
					else:
						write_to_file += key + ","
		
		value_q = [productions[0]]
		while !value_q.is_empty():
			var value = value_q.pop_front()
			if value is Dictionary:
				for key in value.keys():
					if value[key] is Dictionary:
						value_q.append(value[key])
					else:
						write_to_file += key + ","
		
		value_q = [mms_agents[0]]
		while !value_q.is_empty():
			var value = value_q.pop_front()
			if value is Dictionary:
				for key in value.keys():
					if value[key] is Dictionary:
						value_q.append(value[key])
					else:
						write_to_file += key + ","
		
		value_q = [mms_artifacts[0]]
		while !value_q.is_empty():
			var value = value_q.pop_front()
			if value is Dictionary:
				for key in value.keys():
					if value[key] is Dictionary:
						value_q.append(value[key])
					else:
						write_to_file += key + ","
						
		value_q = [mms_productions[0]]
		while !value_q.is_empty():
			var value = value_q.pop_front()
			if value is Dictionary:
				for key in value.keys():
					if value[key] is Dictionary:
						value_q.append(value[key])
					else:
						write_to_file += key + ","
		
		write_to_file += "\n"
		for i in range(agents.size()):
			var val_q : Array = [agents[i]]
			while !val_q.is_empty():
				var value = val_q.pop_front()
				if value is Dictionary:
					for key in value.keys():
						if value[key] is Dictionary:
							val_q.append(value[key])
						else:
							write_to_file += str(value[key]).replace(",",";") + ","
			val_q = [artifacts[i]]
			while !val_q.is_empty():
				var value = val_q.pop_front()
				if value is Dictionary:
					for key in value.keys():
						if value[key] is Dictionary:
							val_q.append(value[key])
						else:
							write_to_file += str(value[key]).replace(",",";") + ","
			val_q = [productions[i]]
			while !val_q.is_empty():
				var value = val_q.pop_front()
				if value is Dictionary:
					for key in value.keys():
						if value[key] is Dictionary:
							val_q.append(value[key])
						else:
							write_to_file += str(value[key]).replace(",",";") + ","
			val_q = [mms_agents[i]]
			while !val_q.is_empty():
				var value = val_q.pop_front()
				if value is Dictionary:
					for key in value.keys():
						if value[key] is Dictionary:
							val_q.append(value[key])
						else:
							write_to_file += str(value[key]).replace(",",";") + ","
			val_q = [mms_artifacts[i]]
			while !val_q.is_empty():
				var value = val_q.pop_front()
				if value is Dictionary:
					for key in value.keys():
						if value[key] is Dictionary:
							val_q.append(value[key])
						else:
							write_to_file += str(value[key]).replace(",",";") + ","
			val_q = [mms_productions[i]]
			while !val_q.is_empty():
				var value = val_q.pop_front()
				if value is Dictionary:
					for key in value.keys():
						if value[key] is Dictionary:
							val_q.append(value[key])
						else:
							write_to_file += str(value[key]).replace(",",";") + ","
			write_to_file += "\n"
	
	var file
	if FileAccess.file_exists(save_path):
		file = FileAccess.open(save_path, FileAccess.READ_WRITE)
	else:
		file = FileAccess.open(save_path, FileAccess.WRITE_READ)
	print(file.get_open_error())
	var file_content = file.get_as_text()
	#for line in write_to_file.split("\n"):
		#file.store_line(line)
	write_to_file = file_content + write_to_file
	file.store_string(write_to_file)
	file.close()
	
	
	
	
	
	
	
	
	
