class_name UIInfluence extends UIListElement

var influence_on : String
var value : float

@export
var value_obj : FloatValueUI
@export
var influence_on_obj : StringValueUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	value_obj.value_changed.connect(_value_changed)
	influence_on_obj.value_changed.connect(_influence_on_changed)

func _influence_on_changed(new_value : String):
	influence_on = new_value

func _value_changed(new_value : float):
	value = new_value

func set_value(new_value : float):
	value_obj.set_value(new_value)

func set_influence_on(new_value : String):
	influence_on_obj.set_value(new_value)
