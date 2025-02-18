class_name Production

var predecessor : String # type of the actor this rule applies to 
var context : String # actor type that is the context
var distance : float # distance to the context for the rule to be applicable
var successor : Array[String] # array containing the types of actors that should succeed the predecessor
var theta : float # probability the rule is chosen from all availabe rules
var persist : bool # true if predecessor persists, false if the predecessor gets replaced

func to_dict() -> Dictionary:
	var dict = {
		"predecessor" : predecessor,
		"context" : context,
		"distance" : distance,
		"successor" : successor,
		"theta" : theta,
		"persist" : persist
	}
	return dict

func from_dict(dictionary : Dictionary) -> void:
	predecessor = dictionary["predecessor"]
	context = dictionary["context"]
	distance = dictionary["distance"]
	for element in dictionary["successor"]:
		successor.append(element)
	theta = dictionary["theta"]
	persist = dictionary["persist"]
