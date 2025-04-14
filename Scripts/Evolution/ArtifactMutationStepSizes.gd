class_name ArtifactMutationStepSizes extends MutationStepSizes

var influence_on_terrain : float = 1.0
var influences : Array[float] = []

func _init() -> void:
	count = 1

func to_dict() -> Dictionary:
	var dict = {
		"influence_on_terrain" : influence_on_terrain
	}
	for i in range(influences.size()):
		dict["influence" + str(i)] = influences[i]
	
	return dict
