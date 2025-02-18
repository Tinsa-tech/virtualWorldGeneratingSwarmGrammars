class_name ArtifactTemplate

extends ActorTemplate

var influence_on_terrain : float
var influences : Dictionary

func to_dict() -> Dictionary:
	var super_string = super.to_dict()
	var dict = {
		"influence_on_terrain" : influence_on_terrain,
		"influences" : influences
	}
	var ret = {
		"Actor" : super_string,
		"Artifact" : dict
	}
	return ret

func from_dict(dictionary : Dictionary) -> void:	
	super.from_dict(dictionary["Actor"])
	
	var dict_artifact = dictionary["Artifact"]
	influence_on_terrain = dict_artifact["influence_on_terrain"]
	influences = dict_artifact["influences"]
