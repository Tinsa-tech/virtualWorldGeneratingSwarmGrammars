class_name EvolutionElement

var genotypes : Database
var actors_mutation_step_sizes : Array[MutationStepSizes]
var productions_mutation_step_sizes : Array[ProductionMutationStepSize]

var fitness : int = 0

func _init() -> void:
	genotypes = Database.new()
	genotypes.random()
	
	actors_mutation_step_sizes = []
	for template in genotypes.templates:
		var mss
		if template is AgentTemplate:
			mss = AgentMutationStepSizes.new()
			for mut in actors_mutation_step_sizes:
				mut.influences.append(1.0)
				mut.count += 1
				if mut is AgentMutationStepSizes:
					mss.influences.append(1.0)
					mss.count += 1
			mss.influences.append(1.0)
			mss.count += 1
		else:
			mss = ArtifactMutationStepSizes.new()
			for mut in actors_mutation_step_sizes:
				if mut is AgentMutationStepSizes:
					mss.influences.append(1.0)
					mss.count += 1
		actors_mutation_step_sizes.append(mss)
		
	
	productions_mutation_step_sizes = []
	for i in range(genotypes.productions.size()):
		var mss = ProductionMutationStepSize.new()
		productions_mutation_step_sizes.append(mss)

func set_fitness(new_fitness : float): 
	fitness = int(new_fitness)
	
