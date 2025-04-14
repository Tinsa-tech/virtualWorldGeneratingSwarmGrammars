class_name SwarmInfo extends HBoxContainer

@export
var agents_container : UIList
@export
var productions_container : UIList
@export
var artifacts_container : UIList
@export
var misc : MiscUI

var data : Database

func _ready() -> void:
	data = Database.new()

func fill_ui():
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
	
	misc.fill(data)

func gather_data() -> Database:
	var templates : Array[ActorTemplate]
	for agent : AgentUI in agents_container.list_elements:
		agent.get_data()
		templates.append(agent.agent_template)
	for artifact : ArtifactUI in artifacts_container.list_elements:
		artifact.get_data()
		templates.append(artifact.artifact)
	
	data.templates = templates
	
	var productions : Array[Production]
	for production : ProductionUI in productions_container.list_elements:
		production.get_data()
		productions.append(production.production)
	
	data.productions = productions
	misc.get_data(data) # already puts stuff in the database
	return data

func clear():
	agents_container.clear()
	artifacts_container.clear()
	productions_container.clear()
	data.clear()

func clear_ui():
	agents_container.clear()
	artifacts_container.clear()
	productions_container.clear()

func set_data(database : Database):
	data = database
	fill_ui()

func lock():
	agents_container.lock()
	productions_container.lock()
	artifacts_container.lock()
	misc.lock()

func unlock():
	agents_container.unlock()
	productions_container.unlock()
	artifacts_container.unlock()
	misc.unlock()
