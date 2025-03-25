class_name SwarmCreation extends Control

@export
var swarm_info : SwarmInfo

@export
var load_button : Button
@export
var file_dialog_load : FileDialog
@export
var save_button : Button
@export
var file_dialog_save : FileDialog
@export
var random_button : Button
@export
var start_button : Button

var data : Database

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_button.pressed.connect(_on_load_button_pressed)
	file_dialog_load.file_selected.connect(_on_file_load_chosen)
	save_button.pressed.connect(_on_save_button_pressed)
	file_dialog_save.file_selected.connect(_on_file_save_chosen)
	start_button.pressed.connect(_on_start_button_pressed)
	random_button.pressed.connect(_on_random_button_pressed)
	
	data = Database.new()

func _on_load_button_pressed():
	file_dialog_load.current_dir = "/Users/jonas/Documents/BachelorArbeit/implementation/virtualWorldGeneratingSwarmGrammars"
	file_dialog_load.add_filter("*.json")
	file_dialog_load.show()

func _on_save_button_pressed():
	file_dialog_save.current_dir = "/Users/jonas/Documents/BachelorArbeit/implementation/virtualWorldGeneratingSwarmGrammars"
	file_dialog_save.add_filter("*.json")
	file_dialog_save.show()

func _on_random_button_pressed():
	clear()
	data.random()
	swarm_info.set_data(data)
	fill_ui()

func _on_start_button_pressed():
	gather_data()
	var swarm_scene : SwarmScene = SceneManager.get_instance().swarm_scene.instantiate()
	get_tree().root.add_child(swarm_scene)
	swarm_scene.init_vsg(data)
	swarm_scene.enable_camera()
	self.hide()

func _on_file_load_chosen(path : String):
	clear()
	data.load_data(path)
	swarm_info.set_data(data)

func _on_file_save_chosen(path : String):
	gather_data()
	data.save_data(path)

func fill_ui():
	swarm_info.fill_ui()

func gather_data():
	data = swarm_info.gather_data()

func clear():
	swarm_info.clear()
