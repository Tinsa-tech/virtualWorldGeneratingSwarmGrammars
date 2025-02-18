class_name Database

var first_generation : Array[String]
var templates : Array[ActorTemplate]
var productions : Array[Production]
var t : float = 1.0
var terrain_size : int = 100

static var instance

enum movement_urges {SEPARATION, ALIGNMENT, COHESION, RANDOM, BIAS,
CENTER, FLOOR, NORMAL, GRADIENT, SLOPE, NOCLIP, PACE, SEED}
enum velocity_params {NORM, MAX}
enum distance_params {VIEW, SEPARATION}
enum energy_params {SUCCESSOR, PERSIST, MOVE}
enum energy_params_modes {CONST, INHERIT, DISTANCE}

static func getInstance() -> Database:
	if instance:
		return instance
	else: 
		instance = Database.new()
		return instance

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
	
	save_file.close()

#func _init() -> void:
#
	#var terrain_agent_template = AgentTemplate.new()
	#terrain_agent_template.type = "TerrainAgent"
	#terrain_agent_template.movement_urges = {
		#movement_urges.CENTER : 0.001,
		#movement_urges.RANDOM : 0.2,
		#movement_urges.PACE : 0.1,
		#movement_urges.NOCLIP : 1
	#}
	#terrain_agent_template.a_max = 0.5
	#terrain_agent_template.velocity_params = {
		#velocity_params.MAX : 2,
		#velocity_params.NORM : 1
	#}
	#terrain_agent_template.constraints = Vector3(1, 0.5, 1)
	#terrain_agent_template.distance_params = {
		#distance_params.SEPARATION : 5,
		#distance_params.VIEW : 100
	#}
	#terrain_agent_template.beta = 180
	#
	#var e_suc = EnergyLSystem.new()
	#e_suc.type = energy_params.SUCCESSOR
	#e_suc.value = 10
	#e_suc.mode = e_suc.Mode.CONST
	#
	#var e_persist = EnergyLSystem.new()
	#e_persist.type = energy_params.PERSIST
	#e_persist.value = 0
	#e_persist.mode = e_persist.Mode.CONST
	#
	#terrain_agent_template.energy_l_system.append_array([e_suc, e_persist])
	#
	#terrain_agent_template.energy_calculations = {
		#energy_params.SUCCESSOR : [energy_params_modes.CONST, 10],
		#energy_params.PERSIST : [energy_params_modes.CONST, 0],
		#energy_params.MOVE : [energy_params_modes.CONST, 0.1],
	#}
	#var ezero = EnergyZero.new()
	#ezero.empty = true
	#terrain_agent_template.energy_zero = ezero
	#
	#templates.append(terrain_agent_template)
	#
	#var terrain_artifact = ArtifactTemplate.new()
	#terrain_artifact.type = "TerrainArtifact"
	#terrain_artifact.influence_on_terrain = 2
	#
	#templates.append(terrain_artifact)
	#
	#var prod1 = Production.new()
	#prod1.predecessor = terrain_agent_template.type
	#prod1.theta = 11
	#prod1.persist = true
	#
	#productions.append(prod1)
	#
	#var prod2 = Production.new()
	#prod2.predecessor = terrain_agent_template.type
	#prod2.theta = 1
	#prod2.persist = true
	#prod2.successor.append(terrain_artifact.type)
	#
	#productions.append(prod2)
	#
	#first_generation.append("TerrainAgent")

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
