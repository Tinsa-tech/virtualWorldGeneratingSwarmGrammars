class_name Energy

enum move {CONST, DISTANCE}
enum successor {
	CONST, ## successor energy = constant value
	INHERIT, ## successor energy = predecessor energy * factor
	DISTRIBUTE, ## successor energy = predecessor energy / successor count
	CONSTDIST ## successor energy = min(constant value, (predecessor energy - constant value) / successor count)
	}
enum predecessor {
	CONST, ## predecessor energy - constant
	PER_SUCCESSOR, ## predecessor energy - successor count * factor
	EQUAL, ## predecessor energy = successor energy
	CONSTDIST ## predecessor energy - constant - successor count * energy each successor has
	}

var move_value : float
var move_mode : int

var successor_value : float
var successor_value_constdist : float
var successor_mode : int

var predecessor_value : float
var predecessor_mode : int

var zero_successors : Array[String] = []
var zero_energy : float

func from_dict(dict : Dictionary):
	move_value = dict["move"]
	move_mode = move_to_int(dict["move_mode"])
	successor_value = dict["successor"]
	successor_value_constdist = dict["successor_constdist"]
	successor_mode = successor_to_int(dict["successor_mode"])
	predecessor_value = dict["predecessor"]
	predecessor_mode = predecessor_to_int(dict["predecessor_mode"])
	zero_successors = dict["zero_successors"]
	zero_energy = dict["zero_energy"]

func to_dict() -> Dictionary:
	var dict = {
		"move" : move_value,
		"move_mode" : move_to_string(move_mode),
		"successor" : successor_value,
		"successor_constdist" : successor_value_constdist,
		"successor_mode" : successor_to_string(successor_mode),
		"predecessor" : predecessor_value,
		"predecessor_mode" : predecessor_to_string(predecessor_mode),
		"zero_successors" : zero_successors,
		"zero_energy" : zero_energy
	}
	return dict

func move_to_string(to_string : int) -> String:
	var ret : String
	match to_string:
		move.CONST:
			ret = "constant"
		move.DISTANCE:
			ret = "distance"
	return ret

func move_to_int(to_int : String) -> int:
	var ret : int
	match to_int:
		"constant":
			ret = move.CONST
		"distance":
			ret = move.DISTANCE
	return ret

func successor_to_string(to_string : int) -> String:
	var ret : String
	match to_string:
		successor.CONST:
			ret = "constant"
		successor.INHERIT:
			ret = "inherit"
		successor.DISTRIBUTE:
			ret = "distribute"
		successor.CONSTDIST:
			ret = "constant_distribute"
	return ret

func successor_to_int(to_int : String) -> int:
	var ret : int
	match to_int:
		"constant":
			ret = successor.CONST
		"inherit":
			ret = successor.INHERIT
		"distribute":
			ret = successor.DISTRIBUTE
		"constant_distribute":
			ret = successor.CONSTDIST
	return ret

func predecessor_to_string(to_string : int) -> String:
	var ret : String
	match to_string:
		predecessor.CONST:
			ret = "constant"
		predecessor.PER_SUCCESSOR:
			ret = "per_successor"
		predecessor.EQUAL:
			ret = "equal"
		predecessor.CONSTDIST:
			ret = "constant distribution"
	return ret

func predecessor_to_int(to_int : String) -> int:
	var ret : int
	match to_int:
		"constant":
			ret = predecessor.CONST
		"per_successor":
			ret = predecessor.PER_SUCCESSOR
		"equal":
			ret = predecessor.EQUAL
		"constant distribution":
			ret = predecessor.CONSTDIST
	return ret
