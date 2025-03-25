class_name Database

var first_generation : Array[String]
var templates : Array[ActorTemplate]
var productions : Array[Production]
var t : float = 1.0
var terrain_size : int = 100
var colors : Dictionary

enum movement_urges {SEPARATION, ALIGNMENT, COHESION, RANDOM, BIAS,
CENTER, FLOOR, NORMAL, GRADIENT, SLOPE, NOCLIP, PACE, SEED}
enum velocity_params {NORM, MAX}
enum distance_params {VIEW, SEPARATION}
enum energy_params {SUCCESSOR, PERSIST, MOVE}
enum energy_params_modes {CONST, INHERIT, DISTANCE}

func save_data(path_to_save : String):
	var dict = {
		"first_generation" : first_generation,
	}
	
	var agent_templates : Array = []
	var artifact_templates : Array = []
	for template in templates:
		if template is AgentTemplate:
			var dict_temp = template.to_dict()
			agent_templates.append(dict_temp)
		elif template is ArtifactTemplate:
			var dict_temp = template.to_dict()
			artifact_templates.append(dict_temp)
	
	dict["agents"] = agent_templates
	dict["artifacts"] = artifact_templates
	
	var production_strings : Array = []
	for production in productions:
		production_strings.append(production.to_dict())
	
	dict["productions"] = production_strings
	
	dict["t"] = t
	dict["terrain_size"] = terrain_size
	
	var save_file = FileAccess.open(path_to_save, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(dict, "\t"))
	save_file.close()

func load_data(path_to_load : String) -> void:
	var save_file = FileAccess.open(path_to_load, FileAccess.READ)
	var json_string = save_file.get_as_text()
	
	var dict = JSON.parse_string(json_string)
	var agent_templates = dict["agents"]
	for agent in agent_templates:
		var template = AgentTemplate.new()
		template.from_dict(agent)
		templates.append(template)
	
	var artifact_templates = dict["artifacts"]
	for artifact in artifact_templates:
		var template = ArtifactTemplate.new()
		template.from_dict(artifact)
		templates.append(template)
	
	var production_dicts = dict["productions"]
	for prod in production_dicts:
		var production = Production.new()
		production.from_dict(prod)
		productions.append(production)
	
	for element in dict["first_generation"]:
		first_generation.append(element)
	
	t = dict["t"]
	terrain_size = dict["terrain_size"]
	
	create_colors()
	
	save_file.close()

## generates a random vSG
func random():
	var rng = RandomNumberGenerator.new	()
	var nr_agents = rng.randi_range(1,5)
	var agents : Array[AgentTemplate] = []
	
	for i in range(nr_agents):
		var agent = AgentTemplate.new()
		agent.type = "agent" + str(i)
		agent.movement_urges[Database.movement_urges.SEPARATION] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.ALIGNMENT] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.COHESION] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.RANDOM] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.CENTER] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.FLOOR] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.GRADIENT] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.NORMAL] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.SLOPE] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.NOCLIP] = rng.randf() > 0.5
		agent.movement_urges[Database.movement_urges.PACE] = rng.randf_range(0.0, 10.0)
		agent.movement_urges[Database.movement_urges.SEED] = rng.randf() > 0.5
		agent.movement_urges[Database.movement_urges.BIAS] = Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0))
		
		agent.a_max = rng.randf() # between 0 and 1 inclusive
		agent.beta = rng.randf_range(0.0, 360.0)
		agent.constraints = Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0))
		
		agent.distance_params[Database.distance_params.VIEW] = rng.randf_range(1.0, 5.0)
		agent.distance_params[Database.distance_params.SEPARATION] = rng.randf_range(0.0, 5.0)
		
		var e_calc = Energy.new()
		e_calc.move_mode = rng.randi_range(0, Energy.move.size() - 1)
		e_calc.move_value = rng.randf_range(0.1, 2.0)
		e_calc.predecessor_mode = rng.randi_range(0, Energy.predecessor.size() - 1)
		e_calc.predecessor_value = rng.randf_range(0.0, 2.0)
		e_calc.successor_mode = rng.randi_range(0, Energy.successor.size() - 1)
		e_calc.successor_value = rng.randf_range(0.0, 2.0)
		e_calc.successor_value_constdist = rng.randf_range(0.0, 2.0)
		e_calc.zero_energy = rng.randf_range(0.0, 10.0)
		# successors need to be done later
		agent.energy_calculations = e_calc
		
		agent.velocity_params[Database.velocity_params.NORM] = rng.randf_range(0.0, 5.0)
		agent.velocity_params[Database.velocity_params.MAX] = rng.randf_range(0.0, 5.0)
		
		# influences need to be done later as well
		
		templates.append(agent)
		agents.append(agent)
	
	var nr_artifacts = rng.randi_range(1, 5)
	var artifacts : Array[ArtifactTemplate] = []
	
	for i in range(nr_artifacts):
		var artifact = ArtifactTemplate.new()
		artifact.type = "artifact" + str(i)
		
		artifact.influence_on_terrain = randf_range(0.0, 10.0)
		
		#influences can only be done when all artifacts and agents are created
		templates.append(artifact)
		artifacts.append(artifact)
	
	# do all influences
	for template in templates:
		for influenced in agents:
			template.influences[influenced.type] = rng.randf_range(0.0, 5.0)
		
		if template is AgentTemplate:
			var e_zero_successor_count = rng.randi_range(0, 5)
			for i in range(e_zero_successor_count):
				var selected = rng.randi_range(0, templates.size() - 2)
				var self_index = templates.find(template)
				if selected >= self_index:
					selected += 1
				template.energy_calculations.zero_successors.append(templates[selected].type)
	var prod_count = rng.randi_range(0, 5)
	
	for i in range(prod_count):
		var production = Production.new()
		
		production.predecessor = Utility.select_random_from_array(agents, rng).type
		
		var has_context = rng.randf()
		if has_context > 0.5:
			production.context = Utility.select_random_from_array(templates, rng).type
		
		production.distance = rng.randf_range(0.0, 5.0)
		production.persist = rng.randf() > 0.5
		production.theta = rng.randf_range(0.0, 100)
		
		var successor_count = rng.randi_range(1, 3)
		
		for j in range(successor_count):
			production.successor.append(Utility.select_random_from_array(templates, rng).type)
		
		productions.append(production)
	
	for agent in agents:
		first_generation.append(agent.type)
	
	create_colors()

func clear():
	templates.clear()
	productions.clear()
	first_generation.clear()
	t = 1.0
	terrain_size = 100

static func movement_urge_to_string(movement_urge : int) -> String:
	var ret : String
	match movement_urge:
		movement_urges.SEPARATION:
			ret = "separation"
		movement_urges.ALIGNMENT:
			ret = "alignment"
		movement_urges.COHESION:
			ret = "cohesion"
		movement_urges.RANDOM:
			ret = "random"
		movement_urges.BIAS:
			ret = "bias"
		movement_urges.CENTER:
			ret = "center"
		movement_urges.FLOOR:
			ret = "floor"
		movement_urges.NORMAL:
			ret = "normal"
		movement_urges.GRADIENT:
			ret = "gradient"
		movement_urges.SLOPE:
			ret = "slope"
		movement_urges.NOCLIP:
			ret = "noclip"
		movement_urges.PACE:
			ret = "pace"
		movement_urges.SEED:
			ret = "seed"
		_:
			ret = "integer out of bounds"
	return ret

static func movement_urge_to_int(movement_urge : String) -> int:
	var ret : int
	match movement_urge:
		"separation":
			ret = movement_urges.SEPARATION
		"alignment":
			ret = movement_urges.ALIGNMENT
		"cohesion":
			ret = movement_urges.COHESION
		"random":
			ret = movement_urges.RANDOM
		"bias":
			ret = movement_urges.BIAS
		"center":
			ret = movement_urges.CENTER
		"floor":
			ret = movement_urges.FLOOR
		"normal":
			ret = movement_urges.NORMAL
		"gradient":
			ret = movement_urges.GRADIENT
		"slope":
			ret = movement_urges.SLOPE
		"noclip":
			ret = movement_urges.NOCLIP
		"pace":
			ret = movement_urges.PACE
		"seed":
			ret = movement_urges.SEED
		_:
			ret = -1
	return ret

static func velocity_params_to_string(velocity_param : int) -> String:
	var ret : String
	match velocity_param:
		velocity_params.NORM: 
			ret = "norm"
		velocity_params.MAX:
			ret = "max"
		_:
			ret = "integer out of bounds"
	return ret

static func velocity_params_to_int(velocity_param : String) -> int:
	var ret : int
	match velocity_param:
		"norm":
			ret = velocity_params.NORM
		"max":
			ret = velocity_params.MAX
		_:
			ret = -1
	return ret

static func distance_params_to_string(distance_param : int) -> String:
	var ret : String
	match distance_param:
		distance_params.VIEW:
			ret = "view"
		distance_params.SEPARATION:
			ret = "separation"
		_:
			ret = "integer out of bounds"
	return ret

static func distance_params_to_int(distance_param : String) -> int:
	var ret : int
	match distance_param:
		"view":
			ret = distance_params.VIEW
		"separation":
			ret = distance_params.SEPARATION
		_:
			ret = -1
	return ret

static func energy_params_to_string(energy_param : int) -> String:
	var ret : String
	match energy_param:
		energy_params.SUCCESSOR:
			ret = "successor"
		energy_params.PERSIST:
			ret = "persist"
		energy_params.MOVE:
			ret = "move"
		_:
			ret = "integer out of bounds"
	return ret

static func energy_params_to_int(energy_param : String) -> int:
	var ret : int
	match energy_param:
		"successor":
			ret = energy_params.SUCCESSOR
		"persist":
			ret = energy_params.PERSIST
		"move":
			ret = energy_params.MOVE
		_:
			ret = -1
	return ret

static func energy_params_mode_to_string(energy_params_mode : int) -> String:
	var ret : String
	match energy_params_mode:
		energy_params_modes.CONST: 
			ret = "const"
		energy_params_modes.INHERIT:
			ret = "inherit"
		energy_params_modes.DISTANCE:
			ret = "distance"
		_:
			ret = "integer out of bounds"
	return ret

static func energy_params_modes_to_int(energy_params_mode : String) -> int:
	var ret : int
	match energy_params_mode:
		"const":
			ret = energy_params_modes.CONST
		"inherit":
			ret = energy_params_modes.INHERIT
		"distance":
			ret = energy_params_modes.DISTANCE
		_:
			ret = -1
	return ret

func add(other : Database):
	for template in other.templates:
		for compare in templates:
			if template.type == compare.type:
				other.change_type(template.type, template.type + "double")
		templates.append(template)
	for production in other.productions:
		productions.append(production)

func change_type(to_change : String, new_type : String):
	for template in templates:
		if template.type == to_change:
			template.type = new_type
		if template is AgentTemplate:
			for type in template.energy_calculations.zero_successors:
				if type == to_change:
					type = to_change
		for key in template.influences.keys():
			if key == to_change:
				template.influences[new_type] = template.influences[key]
				template.influences.erase(key)
	
	for prod in productions:
		if prod.context == to_change:
			prod.context = new_type
		for successor in prod.successor:
			if successor == to_change:
				successor = new_type
		if prod.predecessor == to_change:
			prod.predecessor = new_type

func create_colors():
	var agent_nr = 0
	for template in templates:
		if template is AgentTemplate:
			agent_nr += 1

	var color_distance : float = 1.0 / float(agent_nr)
	var colors_to_distribute : Array[Color] = []
	
	for i in range(agent_nr):
		var deg : float = color_distance * float(i)
		var col = Color.from_hsv(deg, 1.0, 1.0)
		colors_to_distribute.append(col)
	
	var i = 0
	for template in templates:
		if template is AgentTemplate:
			colors[template.type] = colors_to_distribute[i]
			i += 1
