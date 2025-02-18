class_name AgentUI extends UIListElement

var agent_template : AgentTemplate

@export
var type_obj : StringValueUI

@export
var sep_obj : FloatValueUI
@export
var ali_obj : FloatValueUI
@export
var coh_obj : FloatValueUI
@export
var ran_obj : FloatValueUI
@export
var bia_obj : Vector3ValueUI
@export
var cen_obj : FloatValueUI
@export
var flo_obj : FloatValueUI
@export
var nor_obj : FloatValueUI
@export
var gra_obj : FloatValueUI
@export
var slo_obj : FloatValueUI
@export
var pac_obj : FloatValueUI
@export
var noc_obj : BoolValueUI
@export
var see_obj : BoolValueUI

@export
var energy_move_mode_obj : EnumValueUI
@export
var energy_move_value_obj : FloatValueUI
@export
var energy_successor_mode_obj : EnumValueUI
@export
var energy_successor_value_obj : FloatValueUI
@export
var energy_successor_value_2_obj : FloatValueUI
@export
var energy_persist_mode_obj : EnumValueUI
@export
var energy_persist_value_obj : FloatValueUI
@export
var energy_zero_successors_obj : UIList
@export
var energy_zero_value_obj : FloatValueUI

@export
var a_max_obj : FloatValueUI
@export
var v_max_obj : FloatValueUI
@export
var v_norm_obj : FloatValueUI
@export
var view_distance_obj : FloatValueUI
@export
var beta_obj : FloatValueUI
@export
var separation_distance_obj : FloatValueUI
@export
var constraints_obj : Vector3ValueUI

@export
var influences_obj : UIList

@export
var agent_label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	agent_template = AgentTemplate.new()
	type_obj.value_changed.connect(_type_value_changed)
	energy_successor_mode_obj.enum_to_display = Energy.successor
	energy_successor_mode_obj.fill_options()
	energy_move_mode_obj.enum_to_display = Energy.move
	energy_move_mode_obj.fill_options()
	energy_persist_mode_obj.enum_to_display = Energy.predecessor
	energy_persist_mode_obj.fill_options()

func from_template(template : AgentTemplate):
	agent_template = template
	set_type(template.type)
	set_movement_urges(template.movement_urges)
	set_energy(template.energy_calculations)
	set_movement_parameters(template)
	set_influences(template.influences)

func get_data():
	agent_template.type = type_obj.value
	agent_template.a_max = a_max_obj.value
	agent_template.beta = beta_obj.value
	agent_template.constraints = constraints_obj.value
	agent_template.distance_params = {
		Database.distance_params.VIEW : view_distance_obj.value,
		Database.distance_params.SEPARATION : separation_distance_obj.value
	}
	
	agent_template.energy_calculations.move_value = energy_move_value_obj.value
	agent_template.energy_calculations.move_mode = energy_move_mode_obj.value
	agent_template.energy_calculations.successor_value = energy_successor_value_obj.value
	agent_template.energy_calculations.successor_value_constdist = energy_successor_value_2_obj.value
	agent_template.energy_calculations.successor_mode = energy_successor_mode_obj.value
	agent_template.energy_calculations.predecessor_value = energy_persist_value_obj.value
	agent_template.energy_calculations.predecessor_mode = energy_persist_mode_obj.value
	agent_template.energy_calculations.zero_energy = energy_zero_value_obj.value
	
	for member : UIListElementString in energy_zero_successors_obj.list_elements:
		agent_template.energy_calculations.zero_successors.append(member.value)

	var dict : Dictionary
	for influence : UIInfluence in influences_obj.list_elements:
		dict[influence.influence_on] = influence.value
	
	agent_template.influences = dict
	
	agent_template.movement_urges = {
		Database.movement_urges.SEPARATION : sep_obj.value,
		Database.movement_urges.ALIGNMENT : ali_obj.value,
		Database.movement_urges.COHESION : coh_obj.value,
		Database.movement_urges.RANDOM : ran_obj.value,
		Database.movement_urges.BIAS : bia_obj.value,
		Database.movement_urges.CENTER : cen_obj.value,
		Database.movement_urges.FLOOR : flo_obj.value,
		Database.movement_urges.NORMAL : nor_obj.value,
		Database.movement_urges.GRADIENT : gra_obj.value,
		Database.movement_urges.SLOPE : slo_obj.value,
		Database.movement_urges.PACE : pac_obj.value,
		Database.movement_urges.NOCLIP : noc_obj.value,
		Database.movement_urges.SEED : see_obj.value
	}
	agent_template.velocity_params = {
		Database.velocity_params.NORM : v_norm_obj.value,
		Database.velocity_params.MAX : v_max_obj.value
	}

func set_type(new_type : String):
	type_obj.set_value(new_type)
	agent_label.text = new_type

func set_movement_urges(movement_urges : Dictionary):
	for key in movement_urges.keys():
		var value = movement_urges[key]
		match key:
			Database.movement_urges.SEPARATION:
				sep_obj.set_value(value)
			Database.movement_urges.ALIGNMENT:
				ali_obj.set_value(value)
			Database.movement_urges.COHESION:
				coh_obj.set_value(value)
			Database.movement_urges.RANDOM:
				ran_obj.set_value(value)
			Database.movement_urges.BIAS:
				bia_obj.set_value(value)
			Database.movement_urges.CENTER:
				cen_obj.set_value(value)
			Database.movement_urges.FLOOR:
				flo_obj.set_value(value)
			Database.movement_urges.NORMAL:
				nor_obj.set_value(value)
			Database.movement_urges.GRADIENT:
				gra_obj.set_value(value)
			Database.movement_urges.SLOPE:
				slo_obj.set_value(value)
			Database.movement_urges.PACE:
				pac_obj.set_value(value)
			Database.movement_urges.NOCLIP:
				noc_obj.set_value(value)
			Database.movement_urges.SEED:
				see_obj.set_value(value)

func set_energy(energy : Energy):
	energy_successor_mode_obj.set_value(energy.successor_mode)
	energy_successor_value_obj.set_value(energy.successor_value)
	energy_successor_value_2_obj.set_value(energy.successor_value_constdist)
	
	energy_persist_mode_obj.set_value(energy.predecessor_mode)
	energy_persist_value_obj.set_value(energy.predecessor_value)
	
	energy_move_mode_obj.set_value(energy.move_mode)
	energy_move_value_obj.set_value(energy.move_value)
	
	var successors = energy.zero_successors
	for successor in successors:
		energy_zero_successors_obj.add_item()
		var added = energy_zero_successors_obj.list_elements[energy_zero_successors_obj.list_elements.size() - 1]
		added.set_value(successor)
	energy_zero_value_obj.set_value(energy.zero_energy)

func set_movement_parameters(template : AgentTemplate):
	a_max_obj.set_value(template.a_max)
	v_max_obj.set_value(template.velocity_params[Database.velocity_params.MAX])
	v_norm_obj.set_value(template.velocity_params[Database.velocity_params.NORM])
	view_distance_obj.set_value(template.distance_params[Database.distance_params.VIEW])
	beta_obj.set_value(template.beta)
	separation_distance_obj.set_value(template.distance_params[Database.distance_params.SEPARATION])
	constraints_obj.set_value(template.constraints)

func set_influences(influences : Dictionary):
	for key in influences.keys():
		influences_obj.add_item()
		var added : UIInfluence = influences_obj.list_elements[influences_obj.list_elements.size() - 1]
		added.set_influence_on(key)
		added.set_value(influences[key])

func _type_value_changed(new_value : String):
	agent_template.type = new_value
	agent_label.text = new_value
