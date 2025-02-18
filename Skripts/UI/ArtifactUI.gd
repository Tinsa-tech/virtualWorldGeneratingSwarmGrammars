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

func _on_type_changed(new_type : String):
	artifact_label.text = new_type
