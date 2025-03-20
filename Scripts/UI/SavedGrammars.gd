class_name SavedGrammars extends Node

@export
var grid_container : GridContainer
@export
var instantiate_scene : bool = true

var sgs : Array[SavedGrammar] = []

var saved_grammar : PackedScene = preload("res://Scenes/UI/SavedGrammar.tscn")

signal loaded(vsg_loaded, name_loaded)

func _ready() -> void:
	load_grammars()

func load_grammars():
	var dir = DirAccess.open("user://Saved")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			print(file_name)
			if file_name.ends_with(".png"):
				
				var image : Image = Image.new()
				image.load("user://Saved/" + file_name)
				var save_name = file_name.get_slice("img.png", 0)
				var sg : SavedGrammar = saved_grammar.instantiate()
				sg.instantiate_scene = instantiate_scene
				sg.loaded.connect(_on_loaded)
				sgs.append(sg)
				grid_container.add_child(sg)
				sg.fill(save_name, image)
				
			file_name = dir.get_next()

func _on_loaded(vsg_loaded : Database, name_loaded : String):
	loaded.emit(vsg_loaded, name_loaded)
	get_child(0).hide()
