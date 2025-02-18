extends Control

@export
var agents_container : UIList
@export
var productions_container : UIList
@export
var artifacts_container : UIList
@export
var misc : MiscUI

var data : Database

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data = Database.getInstance()
	data.load_data()
	
	for actor in data.templates:
		if actor is AgentTemplate:
			agents_container.add_item()
			var obj : AgentUI = agents_container.get_item(agents_container.size() - 1)
			obj.from_template(actor)
		
		if actor is ArtifactTemplate:
			artifacts_container.add_item()
			var obj : ArtifactUI = artifacts_container.get_item(artifacts_container.size() - 1)
			obj.from_artifact(actor)
	
	for production in data.productions:
		productions_container.add_item()
		var obj : ProductionUI = productions_container.get_item(productions_container.size() - 1)
		obj.from_production(production)
	
	misc.fill()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
