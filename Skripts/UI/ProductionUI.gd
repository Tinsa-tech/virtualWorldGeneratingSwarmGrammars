class_name ProductionUI extends UIListElement

@export
var predecessor_obj : StringValueUI
@export
var context_obj : StringValueUI
@export
var distance_obj : FloatValueUI
@export
var successors_obj : UIList
@export
var theta_obj : FloatValueUI
@export
var persist_obj : BoolValueUI

@export
var prod_label : Label

var production : Production

func _ready() -> void:
	production = Production.new()
	predecessor_obj.value_changed.connect(_on_predecessor_changed)

func from_production(prod : Production):
	production = prod
	prod_label.text = prod.predecessor
	predecessor_obj.set_value(prod.predecessor)
	context_obj.set_value(prod.context)
	distance_obj.set_value(prod.distance)
	for successor in prod.successor:
		successors_obj.add_item()
		var added = successors_obj.get_item(successors_obj.size() - 1)
		added.set_value(successor)
	theta_obj.set_value(prod.theta)
	persist_obj.set_value(prod.persist)

func get_data():
	production.context = context_obj.value
	production.distance = distance_obj.value
	production.persist = persist_obj.value
	production.predecessor = predecessor_obj.value
	var arr
	for succ : UIListElementString in successors_obj.list_elements:
		arr.append(succ.value)
	production.successor = arr
	production.theta = theta_obj.value

func _on_predecessor_changed(new_value : String):
	prod_label.text = new_value
