class_name ArtifactUI extends UIListElement

@export
var type_obj : StringValueUI
@export
var influence_terrain_obj : FloatValueUI
@export
var influences_obj : UIList

@export
var artifact_label : Label

var artifact : ArtifactTemplate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	artifact = ArtifactTemplate.new()
	type_obj.value_changed.connect(_on_type_changed)

func from_artifact(arti : ArtifactTemplate):
	artifact = arti
	type_obj.set_value(arti.type)
	artifact_label.text = arti.type
	influence_terrain_obj.set_value(arti.influence_on_terrain)
	for key in arti.influences.keys():
		influences_obj.add_item()
		var added : UIInfluence = influences_obj.list_elements[influences_obj.list_elements.size() - 1]
		added.set_influence_on(key)
		added.set_value(arti.influences[key])

func get_data():
	artifact.type = type_obj.value
	var dict : Dictionary = {}
	for influence : UIInfluence in influences_obj.list_elements:
		dict[influence.influence_on] = influence.value
	artifact.influences = dict
	artifact.influence_on_terrain = influence_terrain_obj.value

func _on_type_changed(new_type : String):
	artifact_label.text = new_type

func lock():
	type_obj.lock()
	influence_terrain_obj.lock()
	influences_obj.lock()
	super.lock()

func unlock():
	type_obj.unlock()
	influence_terrain_obj.unlock()
	influences_obj.unlock()
	super.unlock()
