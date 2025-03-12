class_name AgentMutationStepSizes extends MutationStepSizes

var a_max : float = 1.0
var beta : float = 1.0

var constraints_x : float = 1.0
var constraints_y : float = 1.0
var constraints_z : float = 1.0

var distance_separation : float = 1.0
var distance_view : float = 1.0

var move_energy : float = 1.0
var predecessor_energy : float = 1.0
var successor_energy : float = 1.0
var successor_const_dist_energy : float = 1.0
var zero_energy : float = 1.0
var zero_successors_length : float = 1.0

var influences : Array[float] = []

var alignment : float = 1.0
var bias_x : float = 1.0
var bias_y : float = 1.0
var bias_z : float = 1.0
var center : float = 1.0
var cohesion : float = 1.0
var floor : float = 1.0
var gradient : float = 1.0
var normal : float = 1.0
var pace : float = 1.0
var random : float = 1.0
var separation : float = 1.0
var slope : float = 1.0

var velocity_max : float = 1.0
var velocity_norm : float = 1.0

func _init() -> void:
	count = 28
