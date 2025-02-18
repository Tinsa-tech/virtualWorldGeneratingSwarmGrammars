extends Control

@export
var agents_container : UIList
@export
var productions_container : UIList
@export
var artifacts_container : UIList
@export
var misc : MiscUI

@export
var load_button : Button
@export
var file_dialog_load : FileDialog
@export
var save_button : Button
@export
var file_dialog_save : FileDialog

var data : Database

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_button.pressed.connect(_on_load_button_pressed)
	file_dialog_load.file_selected.connect(_on_file_load_chosen)
	save_button.pressed.connect(_on_save_button_pressed)
	file_dialog_save.file_selected.connect(_on_file_save_chosen)
	
	data = Database.getInstance()

func _on_load_button_pressed():
	file_dialog_load.current_dir = "/"
	file_dialog_load.add_filter("*.json")
	file_dialog_load.show()

func _on_save_button_pressed():
	file_dialog_save.current_dir = "/"
	file_dialog_save.add_filter("*.json")
	file_dialog_save.show()

func _on_file_load_chosen(path : String):
	data.load_data(path)
	fill_ui()

func _on_file_save_chosen(path : String):
	gather_data()
	data.save_data(path)

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
	
	misc.fill()

func gather_data():
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
	misc.get_data() # already puts stuff in the database
