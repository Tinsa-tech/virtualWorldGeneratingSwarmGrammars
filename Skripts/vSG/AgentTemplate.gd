class_name AgentTemplate

extends ActorTemplate

var movement_urges : Dictionary
var energy_calculations : Energy = Energy.new()
var a_max : float
var velocity_params : Dictionary
var constraints : Vector3
var distance_params : Dictionary
var beta : float
var influences : Dictionary

func to_dict() -> Dictionary:
	var super_string = super.to_dict()
	
	var movement_urges_strings : Dictionary
	for key in movement_urges.keys():
		var string = Database.movement_urge_to_string(key)
		if key == Database.movement_urges.BIAS:
			var bias = movement_urges[key]
			movement_urges_strings[string] = [bias.x, bias.y, bias.z]
		else:
			movement_urges_strings[string] = movement_urges[key]
	
	var velocity_params_strings : Dictionary
	for key in velocity_params:
		var vp = Database.velocity_params_to_string(key)
		velocity_params_strings[vp] = velocity_params[key]
	
	var distance_params_strings : Dictionary
	for key in distance_params:
		var dp = Database.distance_params_to_string(key)
		distance_params_strings[dp] = distance_params[key]
	
	var const_arr = [constraints.x, constraints.y, constraints.z]
	
	var dict = {
		"movement_urges" : movement_urges_strings,
		"energy_calculations" : energy_calculations.to_dict(),
		"a_max" : a_max,
		"velocity_params" : velocity_params_strings,
		"constraints" : const_arr,
		"distance_params" : distance_params_strings,
		"beta" : beta,
		"influences" : influences
	}
	var ret = {
		"Actor" : super_string,
		"Agent" : dict
	}
	return ret

func from_dict(dictionary : Dictionary) -> void:
	
	super.from_dict(dictionary["Actor"])
	var dict_agent = dictionary["Agent"]
	
	var movement_urges_strings = dict_agent["movement_urges"]
	for key in movement_urges_strings.keys():
		var mu = Database.movement_urge_to_int(key)
		if mu == Database.movement_urges.BIAS:
			var bias = movement_urges_strings[key]
			movement_urges[mu] = Vector3(bias[0], bias[1], bias[2])
		else:
			movement_urges[mu] = movement_urges_strings[key]
	
	var e_calc = Energy.new()
	e_calc.from_dict(dict_agent["energy_calculations"])
	energy_calculations = e_calc
	
	a_max = dict_agent["a_max"]
	
	var velocity_params_strings = dict_agent["velocity_params"]
	for key in velocity_params_strings.keys():
		var vp = Database.velocity_params_to_int(key)
		velocity_params[vp] = velocity_params_strings[key]
		
	var const_arr = dict_agent["constraints"]
	constraints.x = const_arr[0]
	constraints.y = const_arr[1]
	constraints.z = const_arr[2]
	
	var distance_params_strings = dict_agent["distance_params"]
	for key in distance_params_strings.keys():
		var dp = Database.distance_params_to_int(key)
		distance_params[dp] = distance_params_strings[key]
	
	beta = dict_agent["beta"]
	influences = dict_agent["influences"]
	
