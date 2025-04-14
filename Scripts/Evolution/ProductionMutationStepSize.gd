class_name ProductionMutationStepSize extends MutationStepSizes

var distance : float = 1.0
var theta : float = 1.0

func _init() -> void:
	count = 2

func to_dict() -> Dictionary:
	var dict = {
		"distance" : distance,
		"theta" : theta
	}
	return dict
