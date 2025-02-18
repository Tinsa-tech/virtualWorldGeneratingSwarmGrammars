class_name Artifact

extends Actor

var influence_on_terrain : float
var influences : Dictionary # influences on other agents or the terrain (String : float) pairs, where the string is the type of the agent that gets influenced

func take_values(template : ActorTemplate):
	influence_on_terrain = template.influence_on_terrain
	influences = template.influences
	super.take_values(template)
	
