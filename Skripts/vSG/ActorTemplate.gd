class_name ActorTemplate

var type : String

func to_dict() -> Dictionary:
	var dict = {"type": type}
	return dict

func from_dict(dictionary : Dictionary):
	if dictionary.has("type"):
		type = dictionary["type"]
	else:
		print("ruh roh, something went wrong when parsing the dictionary in the actor template")
