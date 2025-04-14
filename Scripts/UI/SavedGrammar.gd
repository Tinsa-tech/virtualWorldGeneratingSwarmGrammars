class_name SavedGrammar extends Control

@export
var texture : TextureRect
@export
var load_button : Button
@export
var delete_button : Button
@export
var label : Label

var instantiate_scene : bool = true

var swarm_scene : PackedScene = preload("res://Scenes/SwarmScene.tscn")

signal loaded(vsg_loaded, name_loaded)

func _ready() -> void:
	delete_button.pressed.connect(_on_delete_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)

func _on_load_button_pressed():
	var obj : SwarmScene = swarm_scene.instantiate()
	var data : Database = Database.new()
	data.load_data("user://Saved/" + label.text + ".json")
	if instantiate_scene:
		data.use_rng_seed = true
		get_tree().root.add_child(obj)
		obj.init_vsg(data)
		obj.swarm_info.misc.use_rng_seed_obj.unlock()
		obj.enable_camera()

	
	loaded.emit(data, label.text)
		

func fill(saved_name : String, image : Image):
	label.text = saved_name
	var img_texture : ImageTexture = ImageTexture.create_from_image(image)
	texture.texture = img_texture

func _on_delete_button_pressed():
	pass
